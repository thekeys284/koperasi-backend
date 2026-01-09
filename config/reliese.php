<?php

return [

    'models' => [

        // folder utama untuk model
        'path' => app_path('Models'),
        // namespace untuk model
        'namespace' => 'App\Models',

        // opsi Base model (Reliese akan buat di folder Base)
        'inheritance' => [
            'enabled' => true,
            'base' => 'Base',
        ],

    ],

];
