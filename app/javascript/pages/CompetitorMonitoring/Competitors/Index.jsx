import { router } from '@inertiajs/react'
import { Table, Badge, Button, Group, Text } from '@mantine/core'
import { useTranslation } from 'react-i18next'
import AdminLayout from '../../../components/AdminLayout'

export default function Index({ competitors }) {
  const { t } = useTranslation()

  const toggleActive = (id, active) => {
    router.patch(`/admin/competitor_monitoring/competitors/${id}`, {
      competitor: { active: !active }
    })
  }

  const rows = competitors.map((c) => (
    <Table.Tr key={c.id}>
      <Table.Td><Text fw={500}>{c.name}</Text></Table.Td>
      <Table.Td>{c.industry || '—'}</Table.Td>
      <Table.Td>{c.country || '—'}</Table.Td>
      <Table.Td>
        <Badge color={c.active ? 'green' : 'gray'}>
          {c.active ? t('status.active') : t('status.inactive')}
        </Badge>
      </Table.Td>
      <Table.Td>{c.monitoring_sources_count}</Table.Td>
      <Table.Td>
        <Group gap="xs">
          <Button size="xs" variant="light" component="a"
            href={`/admin/competitor_monitoring/competitors/${c.id}/edit`}>
            {t('actions.edit')}
          </Button>
          <Button size="xs" variant="light" component="a"
            href={`/admin/competitor_monitoring/competitors/${c.id}/monitoring_sources`}>
            {t('competitors.sources')}
          </Button>
          <Button size="xs" variant="subtle" color={c.active ? 'red' : 'green'}
            onClick={() => toggleActive(c.id, c.active)}>
            {c.active ? t('actions.deactivate') : t('actions.activate')}
          </Button>
        </Group>
      </Table.Td>
    </Table.Tr>
  ))

  return (
    <AdminLayout title={t('competitors.title')}>
      <Group justify="flex-end" mb="md">
        <Button component="a" href="/admin/competitor_monitoring/competitors/new">
          {t('competitors.add')}
        </Button>
      </Group>

      {competitors.length === 0 ? (
        <Text c="dimmed">{t('competitors.empty')}</Text>
      ) : (
        <Table striped highlightOnHover>
          <Table.Thead>
            <Table.Tr>
              <Table.Th>{t('common.name')}</Table.Th>
              <Table.Th>{t('common.industry')}</Table.Th>
              <Table.Th>{t('common.country')}</Table.Th>
              <Table.Th>{t('common.status')}</Table.Th>
              <Table.Th>{t('common.sourcesCount')}</Table.Th>
              <Table.Th>{t('common.actions')}</Table.Th>
            </Table.Tr>
          </Table.Thead>
          <Table.Tbody>{rows}</Table.Tbody>
        </Table>
      )}
    </AdminLayout>
  )
}
