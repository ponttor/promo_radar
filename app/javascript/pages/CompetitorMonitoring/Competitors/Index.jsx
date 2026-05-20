import { Table, Badge, Button, Group, Anchor } from '@mantine/core'
import { useTranslation } from 'react-i18next'
import { router } from '@inertiajs/react'
import AdminLayout from '../../../components/AdminLayout'

export default function Index({ competitors }) {
  const { t } = useTranslation()

  const handleDelete = (id, name) => {
    if (confirm(t('actions.confirmDelete', { name }))) {
      router.delete(`/admin/competitor_monitoring/competitors/${id}`)
    }
  }

  const rows = competitors.map((c) => (
    <Table.Tr key={c.id}>
      <Table.Td>
        <Anchor href={`/admin/competitor_monitoring/competitors/${c.id}`} fw={500}>
          {c.name}
        </Anchor>
      </Table.Td>
      <Table.Td>
        <Badge color={c.active ? 'green' : 'gray'} size="sm">
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
          <Button size="xs" variant="light" color="red"
            onClick={() => handleDelete(c.id, c.name)}>
            {t('actions.delete')}
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
              <Table.Th>{t('common.status')}</Table.Th>
              <Table.Th>{t('monitoringSources.count')}</Table.Th>
              <Table.Th>{t('common.actions')}</Table.Th>
            </Table.Tr>
          </Table.Thead>
          <Table.Tbody>{rows}</Table.Tbody>
        </Table>
      )}
    </AdminLayout>
  )
}
