import { Table, Text, Badge, Anchor, Box, Stack } from '@mantine/core'
import { useTranslation } from 'react-i18next'
import AdminLayout from '../../../components/AdminLayout'

const TYPE_COLORS = { daily: 'blue', weekly: 'violet', manual: 'gold' }
const EVENT_COLORS = { created: 'green', updated: 'yellow', ended: 'red', reappeared: 'teal' }
const EVENT_EMOJIS = { created: '🆕', updated: '✏️', ended: '🔚', reappeared: '🔄' }

function formatDateTime(str, lang) {
  if (!str) return '—'
  return new Intl.DateTimeFormat(lang === 'sk' ? 'sk-SK' : 'en-GB', {
    day: '2-digit', month: '2-digit', year: 'numeric',
    hour: '2-digit', minute: '2-digit'
  }).format(new Date(str))
}

export default function Show({ report }) {
  const { t, i18n } = useTranslation()
  const lang = i18n.resolvedLanguage

  return (
    <AdminLayout title={`${t(`reports.${report.report_type}`)} — ${formatDateTime(report.generated_at, lang)}`}>
      <Anchor href="/admin/competitor_monitoring/reports" size="sm" mb="lg" display="block">
        {t('reports.backToReports')}
      </Anchor>

      <Badge color={TYPE_COLORS[report.report_type] || 'gray'} variant="light" mb="lg">
        {t(`reports.${report.report_type}`)} · {report.events_count} {t('reports.eventsCount').toLowerCase()}
      </Badge>

      {/* Markdown rendered as HTML */}
      <Box
        mb="xl"
        style={{
          background: 'var(--gf-surface)',
          border: '1px solid var(--gf-border)',
          borderRadius: 4,
          padding: '24px 32px',
        }}
      >
        <div
          className="report-html"
          dangerouslySetInnerHTML={{ __html: report.summary_html }}
        />
      </Box>

      {/* Events table */}
      {report.items.length > 0 && (
        <Stack gap="sm">
          <Text
            style={{
              fontFamily: '"Cinzel", serif',
              fontSize: 13,
              letterSpacing: '0.08em',
              color: 'var(--gf-text-dim)',
              textTransform: 'uppercase',
            }}
          >
            {t('reports.eventsTable')}
          </Text>
          <Table striped highlightOnHover>
            <Table.Thead>
              <Table.Tr>
                <Table.Th>{t('reports.competitor')}</Table.Th>
                <Table.Th>{t('reports.promotion')}</Table.Th>
                <Table.Th>{t('reports.eventType')}</Table.Th>
                <Table.Th>{t('common.date')}</Table.Th>
              </Table.Tr>
            </Table.Thead>
            <Table.Tbody>
              {report.items.map(item => (
                <Table.Tr key={item.id}>
                  <Table.Td>
                    <Text size="sm">{item.competitor_name}</Text>
                  </Table.Td>
                  <Table.Td>
                    <Anchor
                      href={`/admin/competitor_monitoring/promotions/${item.promotion_id}`}
                      size="sm"
                    >
                      {item.promotion_title || '—'}
                    </Anchor>
                  </Table.Td>
                  <Table.Td>
                    <Badge
                      color={EVENT_COLORS[item.event_type] || 'gray'}
                      variant="light"
                      size="sm"
                    >
                      {EVENT_EMOJIS[item.event_type]} {item.event_type}
                    </Badge>
                  </Table.Td>
                  <Table.Td>
                    <Text size="xs" c="dimmed">{formatDateTime(item.created_at, lang)}</Text>
                  </Table.Td>
                </Table.Tr>
              ))}
            </Table.Tbody>
          </Table>
        </Stack>
      )}
    </AdminLayout>
  )
}
