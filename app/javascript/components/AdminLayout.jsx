import { AppShell, NavLink, Title, SegmentedControl, Stack } from '@mantine/core'
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
            <Title order={5} mb="xl">Promo Radar</Title>
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
          </div>
          <SegmentedControl
            value={i18n.resolvedLanguage || 'en'}
            onChange={(lang) => i18n.changeLanguage(lang)}
            data={[{ label: 'EN', value: 'en' }, { label: 'SK', value: 'sk' }]}
            size="xs"
            fullWidth
          />
        </Stack>
      </AppShell.Navbar>

      <AppShell.Main>
        {title && <Title order={3} mb="lg">{title}</Title>}
        {children}
      </AppShell.Main>
    </AppShell>
  )
}
