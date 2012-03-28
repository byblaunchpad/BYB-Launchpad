<?php
/**
 * @file
 * bybconfigs.features.field.inc
 */

/**
 * Implements hook_field_default_fields().
 */
function bybconfigs_field_default_fields() {
  $fields = array();

  // Exported field: 'node-video-field_description'
  $fields['node-video-field_description'] = array(
    'field_config' => array(
      'active' => '1',
      'cardinality' => '1',
      'deleted' => '0',
      'entity_types' => array(),
      'field_name' => 'field_description',
      'foreign keys' => array(
        'format' => array(
          'columns' => array(
            'format' => 'format',
          ),
          'table' => 'filter_format',
        ),
      ),
      'indexes' => array(
        'format' => array(
          0 => 'format',
        ),
      ),
      'module' => 'text',
      'settings' => array(),
      'translatable' => '0',
      'type' => 'text_long',
    ),
    'field_instance' => array(
      'bundle' => 'video',
      'default_value' => NULL,
      'deleted' => '0',
      'description' => '',
      'display' => array(
        'default' => array(
          'label' => 'above',
          'module' => 'text',
          'settings' => array(),
          'type' => 'text_default',
          'weight' => '1',
        ),
        'teaser' => array(
          'label' => 'above',
          'settings' => array(),
          'type' => 'hidden',
          'weight' => 0,
        ),
      ),
      'entity_type' => 'node',
      'field_name' => 'field_description',
      'label' => 'Description',
      'required' => 0,
      'settings' => array(
        'text_processing' => '1',
        'user_register_form' => FALSE,
      ),
      'widget' => array(
        'active' => 1,
        'module' => 'text',
        'settings' => array(
          'rows' => '5',
        ),
        'type' => 'text_textarea',
        'weight' => '32',
      ),
    ),
  );

  // Exported field: 'node-video-field_video'
  $fields['node-video-field_video'] = array(
    'field_config' => array(
      'active' => '1',
      'cardinality' => '1',
      'deleted' => '0',
      'entity_types' => array(),
      'field_name' => 'field_video',
      'foreign keys' => array(
        'fid' => array(
          'columns' => array(
            'fid' => 'fid',
          ),
          'table' => 'file_managed',
        ),
      ),
      'indexes' => array(
        'fid' => array(
          0 => 'fid',
        ),
      ),
      'module' => 'video',
      'settings' => array(
        'autoconversion' => 0,
        'autothumbnail' => 'auto',
        'default_video_thumbnail' => array(
          'fid' => '1',
          'filemime' => 'image/jpeg',
          'filename' => 'default_thumbnail.jpg',
          'filesize' => 27822,
          'rdf_mapping' => array(),
          'status' => 1,
          'timestamp' => 1318422351,
          'type' => 'image',
          'uid' => '1',
          'uri' => 'public://videos/thumbnails/default/default_thumbnail_0.jpg',
        ),
        'preview_video_thumb_style' => 'thumbnail',
        'uri_scheme' => 'public',
      ),
      'translatable' => '0',
      'type' => 'video',
    ),
    'field_instance' => array(
      'bundle' => 'video',
      'deleted' => '0',
      'description' => '',
      'display' => array(
        'default' => array(
          'label' => 'above',
          'module' => 'video',
          'settings' => array(
            'widthxheight' => '640x360',
          ),
          'type' => 'video_formatter_player',
          'weight' => '0',
        ),
        'teaser' => array(
          'label' => 'above',
          'settings' => array(),
          'type' => 'hidden',
          'weight' => 0,
        ),
      ),
      'entity_type' => 'node',
      'field_name' => 'field_video',
      'label' => 'Video',
      'required' => 0,
      'settings' => array(
        'default_dimensions' => '640x360',
        'file_directory' => 'videos/original',
        'file_extensions' => 'mp4 ogg avi mov wmv flv ogv webm',
        'max_filesize' => '100MB',
        'user_register_form' => FALSE,
      ),
      'widget' => array(
        'active' => 1,
        'module' => 'video',
        'settings' => array(
          'progress_indicator' => 'throbber',
        ),
        'type' => 'video_upload',
        'weight' => '31',
      ),
    ),
  );

  // Translatables
  // Included for use with string extractors like potx.
  t('Description');
  t('Video');

  return $fields;
}
