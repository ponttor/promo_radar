import '@mantine/core/styles.css'
import '../godfather.css'
import '../i18n'
import { createRoot } from 'react-dom/client'
import { createInertiaApp } from '@inertiajs/react'
import { MantineProvider, createTheme } from '@mantine/core'

const theme = createTheme({
  primaryColor: 'gold',
  colors: {
    gold: [
      '#FFF8DC', '#FFE8A3', '#FFD86B', '#F0C842',
      '#D4AF37', '#C9A84C', '#B8960C', '#9A7D0A',
      '#7D6608', '#5A4A00',
    ],
  },
  fontFamily: '"EB Garamond", Georgia, serif',
  headings: { fontFamily: '"Cinzel", "Georgia", serif' },
  defaultRadius: 'xs',
})

createInertiaApp({
  resolve: name => {
    const pages = import.meta.glob('../pages/**/*.jsx', { eager: true })
    return pages[`../pages/${name}.jsx`]
  },
  setup({ el, App, props }) {
    createRoot(el).render(
      <MantineProvider theme={theme} forceColorScheme="dark">
        <App {...props} />
      </MantineProvider>
    )
  },
})
