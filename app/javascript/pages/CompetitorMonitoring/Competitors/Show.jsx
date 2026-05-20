import { Table, Badge, Button, Group, Text, Anchor } from '@mantine/core'
import { useTranslation } from 'react-i18next'
import { router } from '@inertiajs/react'
import AdminLayout from '../../../components/AdminLayout'

export default function Show({ competitor }) {
  const { t } = useTranslation()

  const handleFetch = (source) => {
    router.post(
      `/admin/competitor_monitoring/competitors/${competitor.id}/monitoring_sources/${source.id}/fetch`
    )
  }

  const resultsPath = (source) =>
    source.source_type === 'instagram'
      ? `/admin/competitor_monitoring/competitors/${competitor.id}/monitoring_sources/${source.id}/instagram_posts`
      : `/admin/competitor_monitoring/promotions?source_id=${source.id}`

  const rows = competitor.monitoring_sources.map((source) => (
    <Table.Tr key={source.id}>
      <Table.Td><Text size="sm">{source.url}</Text></Table.Td>
      <Table.Td>
        <Badge variant="light" color={source.source_type === 'instagram' ? 'grape' : 'blue'}>
          {source.source_type}
        </Badge>
      </Table.Td>
      <Table.Td>
        <Group gap="xs" justify="flex-end">
          <Button size="xs" variant="light" color="blue" onClick={() => handleFetch(source)}>
            {t('actions.fetch')}
          </Button>
          <Button size="xs" variant="light" component="a" href={resultsPath(source)}>
            {t('actions.view')}
          </Button>
        </Group>
      </Table.Td>
    </Table.Tr>
  ))

  return (
    <AdminLayout title={competitor.name}>
      <Group mb="md" justify="space-between">
        <Anchor href="/admin/competitor_monitoring/competitors" size="sm">
          {t('nav.backToCompetitors')}
        </Anchor>
        <Group gap="xs">
          <Badge color={competitor.active ? 'green' : 'gray'} variant="light">
            {competitor.active ? t('status.active') : t('status.inactive')}
          </Badge>
          <Button size="xs" variant="light" component="a"
            href={`/admin/competitor_monitoring/competitors/${competitor.id}/edit`}>
            {t('actions.edit')}
          </Button>
        </Group>
      </Group>

      <Text fw={500} mb="xs">{t('monitoringSources.sectionTitle')}</Text>

      {competitor.monitoring_sources.length === 0 ? (
        <Text c="dimmed">{t('monitoringSources.empty')}</Text>
      ) : (
        <Table withTableBorder>
          <Table.Thead>
            <Table.Tr>
              <Table.Th>{t('common.url')}</Table.Th>
              <Table.Th>{t('common.type')}</Table.Th>
              <Table.Th></Table.Th>
            </Table.Tr>
          </Table.Thead>
          <Table.Tbody>{rows}</Table.Tbody>
        </Table>
      )}
    </AdminLayout>
  )
}
