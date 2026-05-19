import { Table, Badge, Button, Group, Text, Anchor } from '@mantine/core'
import { useTranslation } from 'react-i18next'
import AdminLayout from '../../../components/AdminLayout'

function formatDate(dateStr, lang) {
  if (!dateStr) return '—'
  return new Intl.DateTimeFormat(lang === 'sk' ? 'sk-SK' : 'en-GB', {
    day: '2-digit', month: '2-digit', year: 'numeric',
    hour: '2-digit', minute: '2-digit',
  }).format(new Date(dateStr))
}

function statusColor(status) {
  if (status === 'success') return 'green'
  if (status === 'blocked') return 'orange'
  return 'red'
}

export default function Index({ competitor, monitoring_source, snapshots }) {
  const { t, i18n } = useTranslation()

  const rows = snapshots.map((s) => (
    <Table.Tr key={s.id}>
      <Table.Td>
        <Text size="sm">{formatDate(s.fetched_at, i18n.resolvedLanguage)}</Text>
      </Table.Td>
      <Table.Td>
        <Badge color={statusColor(s.status)}>{s.status}</Badge>
      </Table.Td>
      <Table.Td>{s.http_status || '—'}</Table.Td>
      <Table.Td>
        <Text size="xs" ff="monospace">{s.content_hash ? s.content_hash.slice(0, 8) : '—'}</Text>
      </Table.Td>
      <Table.Td>
        <Badge color={s.changed ? 'blue' : 'gray'} variant="light">
          {s.changed ? '✓' : '—'}
        </Badge>
      </Table.Td>
      <Table.Td>
        <Button size="xs" variant="subtle" component="a"
          href={`/admin/competitor_monitoring/competitors/${competitor.id}/monitoring_sources/${monitoring_source.id}/source_snapshots/${s.id}`}>
          {t('actions.view')}
        </Button>
      </Table.Td>
    </Table.Tr>
  ))

  return (
    <AdminLayout title={t('sourceSnapshots.title', { name: monitoring_source.name })}>
      <Group mb="md">
        <Anchor
          href={`/admin/competitor_monitoring/competitors/${competitor.id}/monitoring_sources`}
          size="sm">
          {t('sourceSnapshots.backToSources')}
        </Anchor>
      </Group>

      {snapshots.length === 0 ? (
        <Text c="dimmed">{t('sourceSnapshots.empty')}</Text>
      ) : (
        <Table striped highlightOnHover>
          <Table.Thead>
            <Table.Tr>
              <Table.Th>{t('common.fetchedAt')}</Table.Th>
              <Table.Th>{t('common.status')}</Table.Th>
              <Table.Th>{t('common.httpStatus')}</Table.Th>
              <Table.Th>{t('common.contentHash')}</Table.Th>
              <Table.Th>{t('common.changed')}</Table.Th>
              <Table.Th>{t('common.actions')}</Table.Th>
            </Table.Tr>
          </Table.Thead>
          <Table.Tbody>{rows}</Table.Tbody>
        </Table>
      )}
    </AdminLayout>
  )
}
