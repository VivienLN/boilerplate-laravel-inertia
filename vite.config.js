import { defineConfig } from 'vite';
import laravel from 'laravel-vite-plugin';
import vue from '@vitejs/plugin-vue';

export default defineConfig({
    plugins: [
        laravel({
            input: 'resources/js/app.js',
            refresh: true,
        }),
        vue({
            template: {
                transformAssetUrls: {
                    base: null,
                    includeAbsolute: false,
                },
            },
        }),
    ],
    // Added here to work with docker...
    server: {
      host: true,
      port: 5173,
      watch: {
        usePolling: true
      },
      hmr: {
        host: 'localhost',
      }
    }
});
