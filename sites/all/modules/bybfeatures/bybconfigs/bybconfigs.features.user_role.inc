<?php
/**
 * @file
 * bybconfigs.features.user_role.inc
 */

/**
 * Implements hook_user_default_roles().
 */
function bybconfigs_user_default_roles() {
  $roles = array();

  // Exported role: administrator
  $roles['administrator'] = array(
    'name' => 'administrator',
    'weight' => '2',
  );

  // Exported role: content manager
  $roles['content manager'] = array(
    'name' => 'content manager',
    'weight' => '4',
  );

  // Exported role: site admin
  $roles['site admin'] = array(
    'name' => 'site admin',
    'weight' => '3',
  );

  return $roles;
}
