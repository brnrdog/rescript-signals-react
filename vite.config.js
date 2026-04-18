import { defineConfig } from "vite"
import react from "@vitejs/plugin-react"

export default defineConfig({
  base: "/rescript-signals-react/",
  plugins: [react()],
})
