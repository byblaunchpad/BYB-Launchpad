<?php

function byblaunchpad_install_tasks_alter(&$tasks, $install_state) {
  $newTask['install_set_parameters_form'] = array(
    'display_name' => 'Specify Parameters',
    'run' => $install_state['settings_verified'] ? INSTALL_TASK_SKIP : INSTALL_TASK_RUN_IF_NOT_COMPLETED,
    'type' => 'form'
  ); 
  $newTask2['install_auto_configure'] = array(
    'run' => INSTALL_TASK_RUN_IF_NOT_COMPLETED,
    'display' => false
  );   
  
  $newTasks = array();
  foreach ($tasks as $k => $t) {
    $newTasks[$k] = $t;
    if ($k == 'install_select_profile') {
      $newTasks += $newTask;
    }
    if ($k == 'install_configure_form') {
      $newTasks += $newTask2;
    }    
  }
  $tasks = $newTasks;
  
  $tasks['install_select_locale']['run'] = 1;
  $tasks['install_select_locale']['display'] = false;
  
  $tasks['install_settings_form']['run'] = 1;
  $tasks['install_settings_form']['display'] = false;

  $tasks['install_configure_form']['run'] = 1;
  $tasks['install_configure_form']['display'] = false;
  
  $tasks['install_finished']['function'] = 'install_custom_finished'; 

  //print_r($tasks);die;
}

/*function install_set_parameters_form(&$install_state) {
  drupal_set_title(st('Specify Parameters'));
  
  $install_state['profile_info']['distribution_name'] = 'Drupal';
  $install_state['parameters']['locale'] = 'en';    
  

    include_once DRUPAL_ROOT . '/includes/form.inc';
  //form = drupal_get_form('install_settings_form', $install_state);
    $form = drupal_get_form('install_set_parameters_form', $install_state['parameters']['profile'], $install_state['parameters']['locale']);
    return drupal_render($form);
  
}*/

function install_set_parameters_form($form, &$form_state, &$install_state) {   
  global $databases;
  
  drupal_set_title(st('Specify Parameters'));  
  $install_state['profile_info']['distribution_name'] = 'Drupal';
  $install_state['parameters']['locale'] = 'en';
  
  $profile = $install_state['parameters']['profile'];
  $install_locale = $install_state['parameters']['locale'];

  drupal_static_reset('conf_path');
  $conf_path = './' . conf_path(FALSE);
  $settings_file = $conf_path . '/settings.php';
  $database = isset($databases['default']['default']) ? $databases['default']['default'] : array();

  $drivers = drupal_get_database_types();
  $drivers_keys = array_keys($drivers);

  $form['driver'] = array(
    '#type' => 'radios',
    '#title' => st('Database type'),
    '#required' => TRUE,
    '#default_value' => !empty($database['driver']) ? $database['driver'] : current($drivers_keys),
    '#description' => st('The type of database your @drupal data will be stored in.', array('@drupal' => drupal_install_profile_distribution_name())),
  );
  if (count($drivers) == 1) {
    $form['driver']['#disabled'] = TRUE;
    $form['driver']['#description'] .= ' ' . st('Your PHP configuration only supports a single database type, so it has been automatically selected.');
  }

  // Add driver specific configuration options.
  foreach ($drivers as $key => $driver) {
    $form['driver']['#options'][$key] = $driver->name();

    $form['settings'][$key] = $driver->getFormOptions($database);
    $form['settings'][$key]['#prefix'] = '<h2 class="js-hide">' . st('@driver_name settings', array('@driver_name' => $driver->name())) . '</h2>';
    $form['settings'][$key]['#type'] = 'container';
    $form['settings'][$key]['#tree'] = TRUE;
    $form['settings'][$key]['advanced_options']['#parents'] = array($key);
    $form['settings'][$key]['#states'] = array(
      'visible' => array(
        ':input[name=driver]' => array('value' => $key),
      )
    );
  }

  $form['actions'] = array('#type' => 'actions');
  $form['actions']['save'] = array(
    '#type' => 'submit',
    '#value' => st('Save and continue'),
    '#limit_validation_errors' => array(
      array('driver'),
      array(isset($form_state['input']['driver']) ? $form_state['input']['driver'] : current($drivers_keys)),
    ),
    '#submit' => array('install_set_parameters_form_submit'),
  );

  $form['errors'] = array();
  $form['settings_file'] = array('#type' => 'value', '#value' => $settings_file);

  return $form;  
}

function install_set_parameters_form_validate($form, &$form_state) { 
  $driver = $form_state['values']['driver'];
  $database = $form_state['values'][$driver];
  $database['driver'] = $driver;

  // TODO: remove when PIFR will be updated to use 'db_prefix' instead of
  // 'prefix' in the database settings form.
  $database['prefix'] = $database['db_prefix'];
  unset($database['db_prefix']);

  $form_state['storage']['database'] = $database;
  $errors = install_database_errors($database, $form_state['values']['settings_file']);
  foreach ($errors as $name => $message) {
    form_set_error($name, $message);
  }
}

function install_set_parameters_form_submit($form, &$form_state) {
  global $install_state;

  // Update global settings array and save.
  $settings['databases'] = array(
    'value'    => array('default' => array('default' => $form_state['storage']['database'])),
    'required' => TRUE,
  );
  $settings['drupal_hash_salt'] = array(
    'value'    => drupal_hash_base64(drupal_random_bytes(55)),
    'required' => TRUE,
  );
  drupal_rewrite_settings($settings);
  // Indicate that the settings file has been verified, and check the database
  // for the last completed task, now that we have a valid connection. This
  // last step is important since we want to trigger an error if the new
  // database already has Drupal installed.
  $install_state['settings_verified'] = TRUE;  
  $install_state['completed_task'] = install_verify_completed_task();  
}

function install_auto_configure(&$install_state) {
  global $user;

  variable_set('site_name', st('Site Name'));
  variable_set('site_mail', 'youremail@yourdomain.com');
  variable_set('date_default_timezone', 'UTC');
  variable_set('site_default_country', '');
  
  $preAccount = array(
    'name' => 'admin',
    'mail' => 'siteemail@yourdomain.com',
    'pass' => 'pass',
  );

  // Enable update.module if this option was selected.
  module_enable(array('update'), FALSE);

  // Add the site maintenance account's email address to the list of
  // addresses to be notified when updates are available, if selected.
  variable_set('update_notify_emails', 'youremail@yourdomain.com');

  // We precreated user 1 with placeholder values. Let's save the real values.
  $account = user_load(1);
  $merge_data = array('init' => 'siteemail@yourdomain.com', 'roles' => !empty($account->roles) ? $account->roles : array(), 'status' => 1);
  user_save($account, array_merge($preAccount, $merge_data));
  // Load global $user and perform final login tasks.
  //$user = user_load(1);
  //user_login_finalize();

  variable_set('clean_url', 1);
  
  // Record when this install ran.
  variable_set('install_time', $_SERVER['REQUEST_TIME']);  
}

function install_custom_finished(&$install_state) { 
  drupal_set_title(st('@drupal installation complete', array('@drupal' => drupal_install_profile_distribution_name())), PASS_THROUGH);
  $messages = drupal_set_message();
  $resetUrl = user_pass_reset_url(user_load(1));
  $output = '<p>' . st('Congratulations, you installed @drupal!', array('@drupal' => drupal_install_profile_distribution_name())) . '</p>';
  $output .= '<p>' . (isset($messages['error']) ? st('Review the messages above before logging into <a href="@url">your new site</a>.', array('@url' => $resetUrl)) : st('<a href="@url">Login to your new site</a>.', array('@url' => $resetUrl))) . '</p>';

  // Flush all caches to ensure that any full bootstraps during the installer
  // do not leave stale cached data, and that any content types or other items
  // registered by the install profile are registered correctly.
  drupal_flush_all_caches();

  // Remember the profile which was used.
  variable_set('install_profile', drupal_get_profile());

  // Install profiles are always loaded last
  db_update('system')
    ->fields(array('weight' => 1000))
    ->condition('type', 'module')
    ->condition('name', drupal_get_profile())
    ->execute();

  // Cache a fully-built schema.
  drupal_get_schema(NULL, TRUE);

  // Run cron to populate update status tables (if available) so that users
  // will be warned if they've installed an out of date Drupal version.
  // Will also trigger indexing of profile-supplied content or feeds.
  drupal_cron_run();

  return $output;
}

function byblaunchpad_install_tasks(&$install_state) {
  $tasks['_byblaunchpad_install_other_modules'] = array(
    'display_name' => st('Install Other BYB Launchpad Modules'),
    'display' => FALSE,
    'type' => 'normal',
    'run' => INSTALL_TASK_RUN_IF_NOT_COMPLETED,
  );
  
  $tasks['_byblaunchpad_load_basic_pages'] = array(
    'display_name' => st('Load BYB Launchpad Basic Pages'),
    'display' => FALSE,
    'type' => 'normal',
    'run' => INSTALL_TASK_RUN_IF_NOT_COMPLETED,
  );  
  
  return $tasks;
}

/**
 * Implements hook_form_FORM_ID_alter().
 *
 * Allows the profile to alter the site configuration form.
 */
function byblaunchpad_form_install_configure_form_alter(&$form, $form_state) {
  // Pre-populate the site name with the server name.
  $form['site_information']['site_name']['#default_value'] = $_SERVER['SERVER_NAME'];
}
function _byblaunchpad_install_other_modules() {
  //rest of the modules that can't be 
  //enabled within the .info file
  module_enable(array('media', 'media_browser_plus'));
  
  return NULL;
}

function _byblaunchpad_load_basic_pages() {
  _byblaunchpad_add_node('About Us', 'Placeholder for About Us.', 1);
  _byblaunchpad_add_node('Terms of Service', 'Placeholder for Terms of Service.', 2);
  _byblaunchpad_add_node('Privacy', 'Placeholder for Privacy.', 3);
  _byblaunchpad_add_node('Contact Us', 'Placeholder for Contact Us.', 4);      
}
