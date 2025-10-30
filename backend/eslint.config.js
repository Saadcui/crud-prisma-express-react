import js from "@eslint/js";
import globals from "globals";
import pluginReact from "eslint-plugin-react";
import { defineConfig } from "eslint/config";

export default defineConfig([
  {
    files: ["**/*.{js,mjs,cjs,jsx}"],
    languageOptions: {
      globals: {
        ...globals.browser,
        ...globals.node, // ✅ Allow Node globals (fixes 'process' is not defined)
      },
    },
    extends: [js.configs.recommended], // ✅ Correct syntax
    plugins: {
      react: pluginReact, // ✅ Register the React plugin
    },
    settings: {
      react: {
        version: "detect", // ✅ Automatically detects your React version
      },
    },
    rules: {
      // You can add custom rules here if you want
    },
  },
]);
