import { defineConfig } from 'vitest/config';
import path from 'path';

export default defineConfig({
  resolve: {
    alias: {
      '@src': path.resolve(__dirname, './src'),
      '@fixtures': path.resolve(__dirname, './src/__tests__/fixtures'),
    },
  },
  test: {
    passWithNoTests: true,
  },
});
