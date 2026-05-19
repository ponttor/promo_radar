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

export default function Index({ competitor, monitoring_sources }) {
  const { t, i18n } = useTranslation()

  const rows = monitoring_sources.map((s) => (
    <Table.Tr key={s.id}>
      <Table.Td><Text fw={500}>{s.name}</Text></Table.Td>
      <Table.Td>
        <Anchor href={s.url} target="_blank" size="sm">{s.url}</Anchor>
      </Table.Td>
      <Table.Td><Badge variant="outline">{s.source_type}</Badge></Table.Td>
      <Table.Td>{s.fetch_strategy}</Table.Td>
      <Table.Td>
        <Badge color={s.active ? 'green' : 'gray'} size="sm">
          {s.active ? t('status.active') : t('status.inactive')}
        </Badge>
      </Table.Td>
      <Table.Td>
        <Text size="sm" c="dimmed">{formatDate(s.last_checked_at, i18n.resolvedLanguage)}</Text>
      </Table.Td>
      <Table.Td>
        <Group gap="xs">
          <Button size="xs" variant="light" component="a"
            href={`/admin/competitor_monitoring/competitors/${competitor.id}/monitoring_sources/${s.id}/edit`}>
            {t('actions.edit')}
          </Button>
          <Button size="xs" variant="light" component="a"
            href={`/admin/competitor_monitoring/competitors/${competitor.id}/monitoring_sources/${s.id}/source_snapshots`}>
            {t('monitoringSources.snapshots')}
          </Button>
        </Group>
      </Table.Td>
    </Table.Tr>
  ))

  return (
    <AdminLayout title={t('monitoringSources.title', { name: competitor.name })}>
      <Group mb="md">
        <Anchor href="/admin/competitor_monitoring/competitors" size="sm">
          {t('nav.backToCompetitors')}
        </Anchor>
      </Group>
      <Group justify="flex-end" mb="md">
        <Button component="a"
          href={`/admin/competitor_monitoring/competitors/${competitor.id}/monitoring_sources/new`}>
          {t('monitoringSources.add')}
        </Button>
      </Group>

      {monitoring_sources.length === 0 ? (
        <Text c="dimmed">{t('monitoringSources.empty')}</Text>
      ) : (
        <Table striped highlightOnHover>
          <Table.Thead>
            <Table.Tr>
              <Table.Th>{t('common.name')}</Table.Th>
              <Table.Th>{t('common.url')}</Table.Th>
              <Table.Th>{t('common.type')}</Table.Th>
              <Table.Th>{t('common.strategy')}</Table.Th>
              <Table.Th>{t('common.status')}</Table.Th>
              <Table.Th>{t('common.lastChecked')}</Table.Th>
              <Table.Th>{t('common.actions')}</Table.Th>
            </Table.Tr>
          </Table.Thead>
          <Table.Tbody>{rows}</Table.Tbody>
        </Table>
      )}
    </AdminLayout>
  )
}
