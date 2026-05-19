import '@mantine/core/styles.css'
import '../i18n'
import { createRoot } from 'react-dom/client'
import { createInertiaApp } from '@inertiajs/react'
import { MantineProvider } from '@mantine/core'

createInertiaApp({
  resolve: name => {
    const pages = import.meta.glob('../pages/**/*.jsx', { eager: true })
    return pages[`../pages/${name}.jsx`]
  },
  setup({ el, App, props }) {
    createRoot(el).render(
      <MantineProvider>
        <App {...props} />
      </MantineProvider>
    )
  },
})
