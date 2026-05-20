import { Table, Badge, Button, Group, Select, Text, Anchor } from '@mantine/core'
import { router } from '@inertiajs/react'
import { useTranslation } from 'react-i18next'
import AdminLayout from '../../../components/AdminLayout'

const STATUS_COLORS = { active: 'green', expired: 'red', unknown: 'gray' }
const TYPE_COLORS   = { discount: 'blue', cashback: 'teal', bonus: 'violet', bundle: 'orange', free_shipping: 'cyan' }

function formatDate(dateStr, lang) {
  if (!dateStr) return '—'
  return new Intl.DateTimeFormat(lang === 'sk' ? 'sk-SK' : 'en-GB', {
    day: '2-digit', month: '2-digit', year: 'numeric'
  }).format(new Date(dateStr))
}

export default function Index({ promotions, competitors, enum_options, filters }) {
  const { t, i18n } = useTranslation()
  const lang = i18n.resolvedLanguage

  function applyFilter(key, value) {
    router.get('/admin/competitor_monitoring/promotions', {
      ...filters,
      [key]: value || undefined
    }, { preserveState: true, replace: true })
  }

  const competitorOptions = [
    { value: '', label: t('promotions.filterByCompetitor') },
    ...competitors.map(c => ({ value: String(c.id), label: c.name }))
  ]

  const statusOptions = [
    { value: '', label: t('promotions.filterByStatus') },
    ...enum_options.statuses.map(s => ({ value: s, label: s }))
  ]

  const typeOptions = [
    { value: '', label: t('promotions.filterByType') },
    ...enum_options.promo_types.map(s => ({ value: s, label: s }))
  ]

  const rows = promotions.map(p => (
    <Table.Tr key={p.id}>
      <Table.Td>{p.competitor?.name || '—'}</Table.Td>
      <Table.Td>
        <Text size="sm" fw={500}>{p.canonical_title || '—'}</Text>
      </Table.Td>
      <Table.Td>
        {p.promo_type && (
          <Badge color={TYPE_COLORS[p.promo_type] || 'gray'} variant="light" size="sm">
            {p.promo_type}
          </Badge>
        )}
      </Table.Td>
      <Table.Td>
        <Badge color={STATUS_COLORS[p.status] || 'gray'} size="sm">{p.status}</Badge>
      </Table.Td>
      <Table.Td>
        {p.current_discount_value ? `${p.current_discount_value}%` : '—'}
      </Table.Td>
      <Table.Td>
        <Text size="xs" ff="monospace">{p.current_promo_code || '—'}</Text>
      </Table.Td>
      <Table.Td>
        <Text size="xs" c="dimmed">{formatDate(p.last_seen_at, lang)}</Text>
      </Table.Td>
      <Table.Td>
        <Button
          size="xs"
          variant="subtle"
          component="a"
          href={`/admin/competitor_monitoring/promotions/${p.id}`}
        >
          {t('actions.view')}
        </Button>
      </Table.Td>
    </Table.Tr>
  ))

  return (
    <AdminLayout title={t('promotions.title')}>
      {filters.source_url && (
        <Group mb="sm" gap="xs">
          <Text size="sm" c="dimmed">Source:</Text>
          <Text size="sm" fw={500}>{filters.source_url}</Text>
          <Anchor size="sm" href="/admin/competitor_monitoring/promotions">✕ clear</Anchor>
        </Group>
      )}
      <Group mb="md" gap="sm">
        <Select
          data={competitorOptions}
          value={filters.competitor_id || ''}
          onChange={v => applyFilter('competitor_id', v)}
          size="sm"
          w={200}
        />
        <Select
          data={statusOptions}
          value={filters.status || ''}
          onChange={v => applyFilter('status', v)}
          size="sm"
          w={160}
        />
        <Select
          data={typeOptions}
          value={filters.promo_type || ''}
          onChange={v => applyFilter('promo_type', v)}
          size="sm"
          w={160}
        />
      </Group>

      {promotions.length === 0 ? (
        <Text c="dimmed">{t('promotions.empty')}</Text>
      ) : (
        <Table striped highlightOnHover>
          <Table.Thead>
            <Table.Tr>
              <Table.Th>{t('promotions.competitor')}</Table.Th>
              <Table.Th>{t('promotions.canonicalTitle')}</Table.Th>
              <Table.Th>{t('promotions.promoType')}</Table.Th>
              <Table.Th>{t('common.status')}</Table.Th>
              <Table.Th>{t('promotions.discount')}</Table.Th>
              <Table.Th>{t('promotions.promoCode')}</Table.Th>
              <Table.Th>{t('promotions.lastSeen')}</Table.Th>
              <Table.Th>{t('common.actions')}</Table.Th>
            </Table.Tr>
          </Table.Thead>
          <Table.Tbody>{rows}</Table.Tbody>
        </Table>
      )}
    </AdminLayout>
  )
}
