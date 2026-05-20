import { Anchor, Badge, Table, Text } from '@mantine/core'
import AdminLayout from '../../../components/AdminLayout'

function formatDate(dateStr) {
  if (!dateStr) return '—'
  return new Intl.DateTimeFormat('en-GB', { day: '2-digit', month: '2-digit', year: 'numeric', hour: '2-digit', minute: '2-digit' }).format(new Date(dateStr))
}

export default function Index({ competitor, source, snapshots }) {
  const showPath = (s) =>
    `/admin/competitor_monitoring/competitors/${competitor.id}/monitoring_sources/${source.id}/source_snapshots/${s.id}`

  const rows = snapshots.map((s) => (
    <Table.Tr key={s.id}>
      <Table.Td>
        <Anchor href={showPath(s)} size="sm">#{s.id}</Anchor>
      </Table.Td>
      <Table.Td>
        <Badge variant="light" color={s.status === 'success' ? 'green' : 'red'} size="sm">
          {s.status}
        </Badge>
      </Table.Td>
      <Table.Td><Text size="sm" c="dimmed">{formatDate(s.fetched_at)}</Text></Table.Td>
      <Table.Td><Text size="sm" c="dimmed" lineClamp={1}>{s.visible_text_preview}</Text></Table.Td>
    </Table.Tr>
  ))

  return (
    <AdminLayout title={`Snapshots — ${source.url}`}>
      <Anchor
        href={`/admin/competitor_monitoring/competitors/${competitor.id}`}
        size="sm" mb="md" display="block"
      >
        ← {competitor.name}
      </Anchor>

      {snapshots.length === 0 ? (
        <Text c="dimmed">No snapshots yet.</Text>
      ) : (
        <Table withTableBorder>
          <Table.Thead>
            <Table.Tr>
              <Table.Th>ID</Table.Th>
              <Table.Th>Status</Table.Th>
              <Table.Th>Fetched at</Table.Th>
              <Table.Th>Preview</Table.Th>
            </Table.Tr>
          </Table.Thead>
          <Table.Tbody>{rows}</Table.Tbody>
        </Table>
      )}
    </AdminLayout>
  )
}
