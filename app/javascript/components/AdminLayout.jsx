import { AppShell, NavLink, Stack, Text, Box, SegmentedControl } from '@mantine/core'
import { Link, usePage } from '@inertiajs/react'
import { useTranslation } from 'react-i18next'

export default function AdminLayout({ children, title }) {
  const { url } = usePage()
  const { t, i18n } = useTranslation()

  return (
    <AppShell navbar={{ width: 220, breakpoint: 'sm' }} padding="md">
      <AppShell.Navbar p="md">
        <Stack h="100%" justify="space-between">
          <div>
            <Box mb="xl" style={{ borderBottom: '1px solid rgba(201,168,76,0.25)', paddingBottom: 16 }}>
              <Text
                style={{
                  fontFamily: '"Cinzel", serif',
                  fontSize: 18,
                  fontWeight: 700,
                  color: '#C9A84C',
                  letterSpacing: '0.12em',
                  lineHeight: 1.2,
                }}
              >
                ⚜ CONSIGLIERE
              </Text>
              <Text
                style={{
                  fontFamily: '"EB Garamond", Georgia, serif',
                  fontSize: 11,
                  fontStyle: 'italic',
                  color: '#5A4E3A',
                  letterSpacing: '0.06em',
                  marginTop: 2,
                }}
              >
                intelligence gathering
              </Text>
            </Box>

            <NavLink
              label={t('nav.competitors')}
              component={Link}
              href="/admin/competitor_monitoring/competitors"
              active={url.startsWith('/admin/competitor_monitoring/competitors')}
            />
            <NavLink
              label={t('nav.promotions')}
              component={Link}
              href="/admin/competitor_monitoring/promotions"
              active={url.startsWith('/admin/competitor_monitoring/promotions')}
            />
            <NavLink
              label={t('nav.reports')}
              component={Link}
              href="/admin/competitor_monitoring/reports"
              active={url.startsWith('/admin/competitor_monitoring/reports')}
            />
          </div>

          <Stack gap="xs">
            <Text style={{ fontFamily: '"Cinzel", serif', fontSize: 9, color: '#3A3020', letterSpacing: '0.1em', textAlign: 'center' }}>
              OMERTÀ
            </Text>
            <SegmentedControl
              value={i18n.resolvedLanguage || 'en'}
              onChange={(lang) => i18n.changeLanguage(lang)}
              data={[{ label: 'EN', value: 'en' }, { label: 'SK', value: 'sk' }]}
              size="xs"
              fullWidth
            />
          </Stack>
        </Stack>
      </AppShell.Navbar>

      <AppShell.Main>
        {title && (
          <Text
            component="h1"
            mb="lg"
            style={{
              fontFamily: '"Cinzel", serif',
              fontSize: 22,
              fontWeight: 600,
              color: '#C9A84C',
              letterSpacing: '0.06em',
              margin: 0,
              marginBottom: 24,
            }}
          >
            {title}
          </Text>
        )}
        {children}
      </AppShell.Main>
    </AppShell>
  )
}
