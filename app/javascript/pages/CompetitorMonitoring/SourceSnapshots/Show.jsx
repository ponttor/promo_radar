import { Text, Badge, Group, Anchor, Code, ScrollArea, Accordion, Title, Stack } from '@mantine/core'
import { useTranslation } from 'react-i18next'
import AdminLayout from '../../../components/AdminLayout'

function statusColor(status) {
  if (status === 'success') return 'green'
  if (status === 'blocked') return 'orange'
  return 'red'
}

function formatDate(dateStr, lang) {
  if (!dateStr) return '—'
  return new Intl.DateTimeFormat(lang === 'sk' ? 'sk-SK' : 'en-GB', {
    day: '2-digit', month: '2-digit', year: 'numeric',
    hour: '2-digit', minute: '2-digit', second: '2-digit',
  }).format(new Date(dateStr))
}

export default function Show({ competitor, monitoring_source, snapshot }) {
  const { t, i18n } = useTranslation()

  return (
    <AdminLayout title={`Snapshot #${snapshot.id}`}>
      <Group mb="md">
        <Anchor
          href={`/admin/competitor_monitoring/competitors/${competitor.id}/monitoring_sources/${monitoring_source.id}/source_snapshots`}
          size="sm">
          {t('sourceSnapshots.backToSources')}
        </Anchor>
      </Group>

      <Group mb="lg" gap="xl" align="flex-start">
        <Stack gap={2}>
          <Text size="xs" c="dimmed">{t('common.status')}</Text>
          <Badge color={statusColor(snapshot.status)}>{snapshot.status}</Badge>
        </Stack>
        <Stack gap={2}>
          <Text size="xs" c="dimmed">{t('common.fetchedAt')}</Text>
          <Text size="sm">{formatDate(snapshot.fetched_at, i18n.resolvedLanguage)}</Text>
        </Stack>
        {snapshot.http_status && (
          <Stack gap={2}>
            <Text size="xs" c="dimmed">{t('common.httpStatus')}</Text>
            <Text size="sm">{snapshot.http_status}</Text>
          </Stack>
        )}
        {snapshot.title && (
          <Stack gap={2}>
            <Text size="xs" c="dimmed">Title</Text>
            <Text size="sm">{snapshot.title}</Text>
          </Stack>
        )}
      </Group>

      {snapshot.error_message && (
        <Text c="red" mb="md">{t('common.errorMessage')}: {snapshot.error_message}</Text>
      )}

      {snapshot.visible_text && (
        <>
          <Title order={5} mb="xs">{t('common.visibleText')}</Title>
          <ScrollArea h={300} mb="lg">
            <Code block style={{ whiteSpace: 'pre-wrap' }}>{snapshot.visible_text}</Code>
          </ScrollArea>
        </>
      )}

      {snapshot.meta_json && Object.keys(snapshot.meta_json).length > 0 && (
        <Accordion mb="lg">
          <Accordion.Item value="meta">
            <Accordion.Control>{t('common.metadata')}</Accordion.Control>
            <Accordion.Panel>
              <Code block>{JSON.stringify(snapshot.meta_json, null, 2)}</Code>
            </Accordion.Panel>
          </Accordion.Item>
        </Accordion>
      )}
    </AdminLayout>
  )
}
