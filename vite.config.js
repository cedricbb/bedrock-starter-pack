import { defineConfig } from 'vite';

export default defineConfig({
  root: 'web/app/themes/your-theme',
  base: '/app/themes/your-theme/dist/',
  
  build: {
    outDir: 'dist',
    manifest: true,
    rollupOptions: {
      input: {
        main: 'web/app/themes/your-theme/assets/js/main.js',
        style: 'web/app/themes/your-theme/assets/css/style.css',
      },
    },
  },

  server: {
    host: '0.0.0.0',
    port: 3000,
    strictPort: true,
    hmr: {
      host: 'localhost',
      protocol: 'ws',
    },
  },
});
