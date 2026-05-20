import {
  Badge, Timeline, Text, Title, Stack, Group, Anchor,
  Table, Paper, Divider
} from '@mantine/core'
import { useTranslation } from 'react-i18next'
import AdminLayout from '../../../components/AdminLayout'

const STATUS_COLORS = { active: 'green', expired: 'red', unknown: 'gray' }
const EVENT_COLORS  = { created: 'green', updated: 'blue', ended: 'red', reappeared: 'teal' }

function formatDate(dateStr, lang) {
  if (!dateStr) return '—'
  return new Intl.DateTimeFormat(lang === 'sk' ? 'sk-SK' : 'en-GB', {
    day: '2-digit', month: '2-digit', year: 'numeric',
    hour: '2-digit', minute: '2-digit'
  }).format(new Date(dateStr))
}

function ChangeSummary({ summary, t }) {
  if (!summary || Object.keys(summary).length === 0) return null
  return (
    <Table fz="xs" mt="xs">
      <Table.Thead>
        <Table.Tr>
          <Table.Th>{t('common.name')}</Table.Th>
          <Table.Th>{t('promotions.from')}</Table.Th>
          <Table.Th>{t('promotions.to')}</Table.Th>
        </Table.Tr>
      </Table.Thead>
      <Table.Tbody>
        {Object.entries(summary).map(([field, diff]) => (
          <Table.Tr key={field}>
            <Table.Td ff="monospace">{field}</Table.Td>
            <Table.Td c="red">{diff.from || '—'}</Table.Td>
            <Table.Td c="green">{diff.to || '—'}</Table.Td>
          </Table.Tr>
        ))}
      </Table.Tbody>
    </Table>
  )
}

export default function Show({ promotion, versions, events }) {
  const { t, i18n } = useTranslation()
  const lang = i18n.resolvedLanguage

  const timelineItems = events.map((ev, i) => (
    <Timeline.Item
      key={ev.id}
      bullet={<Text size="xs">{i + 1}</Text>}
      title={
        <Badge color={EVENT_COLORS[ev.event_type] || 'gray'} size="sm">
          {ev.event_type}
        </Badge>
      }
    >
      <Text size="xs" c="dimmed">{formatDate(ev.created_at, lang)}</Text>
    </Timeline.Item>
  ))

  const versionRows = versions.map(v => (
    <Table.Tr key={v.id}>
      <Table.Td><Text size="xs" c="dimmed">{formatDate(v.created_at, lang)}</Text></Table.Td>
      <Table.Td>{v.title || '—'}</Table.Td>
      <Table.Td>{v.discount_value ? `${v.discount_value}%` : '—'}</Table.Td>
      <Table.Td><Text ff="monospace" size="xs">{v.promo_code || '—'}</Text></Table.Td>
      <Table.Td>
        <ChangeSummary summary={v.change_summary_json} t={t} />
      </Table.Td>
    </Table.Tr>
  ))

  return (
    <AdminLayout title={promotion.canonical_title || '—'}>
      <Anchor href="/admin/competitor_monitoring/promotions" size="sm" mb="md" display="block">
        {t('promotions.backToPromotions')}
      </Anchor>

      <Paper withBorder p="md" mb="xl">
        <Group gap="xs" mb="xs">
          <Badge color={STATUS_COLORS[promotion.status] || 'gray'}>{promotion.status}</Badge>
          {promotion.promo_type && (
            <Badge variant="light">{promotion.promo_type}</Badge>
          )}
        </Group>
        <Text size="sm"><strong>{t('promotions.competitor')}:</strong> {promotion.competitor?.name || '—'}</Text>
        <Text size="sm"><strong>{t('promotions.firstSeen')}:</strong> {formatDate(promotion.first_seen_at, lang)}</Text>
        <Text size="sm"><strong>{t('promotions.lastSeen')}:</strong> {formatDate(promotion.last_seen_at, lang)}</Text>
      </Paper>

      <Stack gap="xl">
        <div>
          <Title order={5} mb="md">{t('promotions.events')}</Title>
          {events.length === 0 ? (
            <Text c="dimmed" size="sm">{t('promotions.noEvents')}</Text>
          ) : (
            <Timeline active={events.length - 1} bulletSize={24} lineWidth={2}>
              {timelineItems}
            </Timeline>
          )}
        </div>

        <Divider />

        <div>
          <Title order={5} mb="md">{t('promotions.versions')}</Title>
          {versions.length === 0 ? (
            <Text c="dimmed" size="sm">{t('promotions.noVersions')}</Text>
          ) : (
            <Table striped>
              <Table.Thead>
                <Table.Tr>
                  <Table.Th>{t('common.date')}</Table.Th>
                  <Table.Th>{t('promotions.canonicalTitle')}</Table.Th>
                  <Table.Th>{t('promotions.discount')}</Table.Th>
                  <Table.Th>{t('promotions.promoCode')}</Table.Th>
                  <Table.Th>{t('promotions.changedFields')}</Table.Th>
                </Table.Tr>
              </Table.Thead>
              <Table.Tbody>{versionRows}</Table.Tbody>
            </Table>
          )}
        </div>
      </Stack>
    </AdminLayout>
  )
}
