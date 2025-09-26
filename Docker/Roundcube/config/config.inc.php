<?php
    $config['plugins'] = [
        'archive',
        'ziddownload',
        'identity_switch',
        'calendar',
    ];
    $config['log_driver'] = 'stdout';
    $config['zipdownload_selection'] = true;
    $config['des_key'] = 'LRCuTWHQPr9mqS46CdeUJ9QI';
    $config['enable_spellcheck'] = true;
    $config['spellcheck_engine'] = 'pspell';
    $config['imap_vendor'] = 'cyrus';
    include(__DIR__ . '/config.docker.inc.php');
