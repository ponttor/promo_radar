import { Accordion, Anchor, Badge, Code, Group, Stack, Table, Text, Title } from '@mantine/core'
import AdminLayout from '../../../components/AdminLayout'

function formatDate(dateStr) {
  if (!dateStr) return '—'
  return new Intl.DateTimeFormat('en-GB', { day: '2-digit', month: '2-digit', year: 'numeric', hour: '2-digit', minute: '2-digit' }).format(new Date(dateStr))
}

const methodColor = (method) => {
  if (method === 'llm')        return 'violet'
  if (method === 'rule_based') return 'blue'
  if (method === 'hybrid')     return 'teal'
  return 'gray'
}

const methodLabel = (method) => {
  if (method === 'llm')        return 'LLM'
  if (method === 'rule_based') return 'Rule-based'
  if (method === 'hybrid')     return 'Hybrid'
  return method ?? '—'
}

export default function Show({ competitor, source, snapshot, candidates }) {
  const backPath = `/admin/competitor_monitoring/competitors/${competitor.id}/monitoring_sources/${source.id}/source_snapshots`

  const rows = candidates.map((c) => {
    const method   = c.raw_extraction_json?.extraction_method
    const model    = c.raw_extraction_json?.llm_model
    const provider = c.raw_extraction_json?.llm_provider

    return (
      <Table.Tr key={c.id}>
        <Table.Td><Text size="sm" fw={500}>{c.title || '—'}</Text></Table.Td>
        <Table.Td><Badge variant="light" size="sm">{c.promo_type}</Badge></Table.Td>
        <Table.Td>
          <Stack gap={2}>
            <Badge variant="light" color={methodColor(method)} size="sm">
              {methodLabel(method)}
            </Badge>
            {model && <Text size="xs" c="dimmed">{provider ? `${provider}/` : ''}{model}</Text>}
          </Stack>
        </Table.Td>
        <Table.Td><Text size="sm">{Math.round(c.confidence * 100)}%</Text></Table.Td>
        <Table.Td>
          <Accordion variant="default" chevronPosition="left">
            <Accordion.Item value={String(c.id)}>
              <Accordion.Control><Text size="xs" c="dimmed">raw JSON</Text></Accordion.Control>
              <Accordion.Panel>
                <Code block style={{ fontSize: 11 }}>
                  {JSON.stringify(c.raw_extraction_json, null, 2)}
                </Code>
              </Accordion.Panel>
            </Accordion.Item>
          </Accordion>
        </Table.Td>
      </Table.Tr>
    )
  })

  return (
    <AdminLayout title={`Snapshot #${snapshot.id}`}>
      <Anchor href={backPath} size="sm" mb="md" display="block">
        ← {source.url}
      </Anchor>

      <Stack gap="xs" mb="lg">
        <Group gap="xs">
          <Badge variant="light" color={snapshot.status === 'success' ? 'green' : 'red'}>
            {snapshot.status}
          </Badge>
          <Text size="sm" c="dimmed">{formatDate(snapshot.fetched_at)}</Text>
        </Group>
        <Text size="sm" c="dimmed" lineClamp={2}>{snapshot.visible_text_preview}</Text>
      </Stack>

      <Title order={5} mb="xs">
        Extraction Results ({candidates.length})
      </Title>

      {candidates.length === 0 ? (
        <Text c="dimmed" size="sm">No candidates found.</Text>
      ) : (
        <Table withTableBorder withColumnBorders>
          <Table.Thead>
            <Table.Tr>
              <Table.Th>Title</Table.Th>
              <Table.Th>Type</Table.Th>
              <Table.Th>Method</Table.Th>
              <Table.Th>Confidence</Table.Th>
              <Table.Th>Raw</Table.Th>
            </Table.Tr>
          </Table.Thead>
          <Table.Tbody>{rows}</Table.Tbody>
        </Table>
      )}
    </AdminLayout>
  )
}
