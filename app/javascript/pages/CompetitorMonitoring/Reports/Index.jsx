import { useState } from 'react'
import { Table, Button, Text, Group, Badge, Modal, Stack } from '@mantine/core'
import { router } from '@inertiajs/react'
import { useTranslation } from 'react-i18next'
import AdminLayout from '../../../components/AdminLayout'

const TYPE_COLORS = { daily: 'blue', weekly: 'violet', manual: 'gold' }

function formatDateTime(str, lang) {
  if (!str) return '—'
  return new Intl.DateTimeFormat(lang === 'sk' ? 'sk-SK' : 'en-GB', {
    day: '2-digit', month: '2-digit', year: 'numeric',
    hour: '2-digit', minute: '2-digit'
  }).format(new Date(str))
}

function todayIso() {
  return new Date().toISOString().slice(0, 10)
}

function yesterdayIso() {
  const d = new Date()
  d.setDate(d.getDate() - 1)
  return d.toISOString().slice(0, 10)
}

export default function Index({ reports }) {
  const { t, i18n } = useTranslation()
  const lang = i18n.resolvedLanguage
  const [modalOpen, setModalOpen] = useState(false)
  const [from, setFrom] = useState(yesterdayIso())
  const [to, setTo] = useState(todayIso())
  const [loading, setLoading] = useState(false)

  function handleGenerate() {
    setLoading(true)
    router.post('/admin/competitor_monitoring/reports', { from, to }, {
      onSuccess: () => setModalOpen(false),
      onFinish:  () => setLoading(false)
    })
  }

  const rows = reports.length === 0
    ? (
      <Table.Tr>
        <Table.Td colSpan={4}>
          <Text c="dimmed" size="sm" ta="center" py="xl">{t('reports.empty')}</Text>
        </Table.Td>
      </Table.Tr>
    )
    : reports.map(r => (
      <Table.Tr key={r.id}>
        <Table.Td>
          <Badge color={TYPE_COLORS[r.report_type] || 'gray'} variant="light" size="sm">
            {t(`reports.${r.report_type}`)}
          </Badge>
        </Table.Td>
        <Table.Td>
          <Text size="sm">{formatDateTime(r.generated_at, lang)}</Text>
        </Table.Td>
        <Table.Td>
          <Text size="sm">{r.events_count}</Text>
        </Table.Td>
        <Table.Td>
          <Button
            size="xs"
            variant="subtle"
            component="a"
            href={`/admin/competitor_monitoring/reports/${r.id}`}
          >
            {t('actions.view')}
          </Button>
        </Table.Td>
      </Table.Tr>
    ))

  return (
    <AdminLayout title={t('reports.title')}>
      <Group justify="flex-end" mb="md">
        <Button variant="filled" size="sm" onClick={() => setModalOpen(true)}>
          {t('reports.generateManual')}
        </Button>
      </Group>

      <Table striped highlightOnHover>
        <Table.Thead>
          <Table.Tr>
            <Table.Th>{t('reports.type')}</Table.Th>
            <Table.Th>{t('reports.generatedAt')}</Table.Th>
            <Table.Th>{t('reports.eventsCount')}</Table.Th>
            <Table.Th>{t('common.actions')}</Table.Th>
          </Table.Tr>
        </Table.Thead>
        <Table.Tbody>{rows}</Table.Tbody>
      </Table>

      <Modal
        opened={modalOpen}
        onClose={() => setModalOpen(false)}
        title={t('reports.generateManual')}
        size="sm"
      >
        <Stack gap="sm">
          <div>
            <Text size="xs" fw={600} mb={4} style={{ fontFamily: '"Cinzel", serif', letterSpacing: '0.06em' }}>
              {t('reports.from')}
            </Text>
            <input
              type="date"
              value={from}
              onChange={e => setFrom(e.target.value)}
              style={{
                width: '100%',
                background: 'var(--gf-surface)',
                border: '1px solid var(--gf-border)',
                color: 'var(--gf-text)',
                padding: '8px 12px',
                fontFamily: '"EB Garamond", Georgia, serif',
                fontSize: 15,
                borderRadius: 2,
              }}
            />
          </div>
          <div>
            <Text size="xs" fw={600} mb={4} style={{ fontFamily: '"Cinzel", serif', letterSpacing: '0.06em' }}>
              {t('reports.to')}
            </Text>
            <input
              type="date"
              value={to}
              onChange={e => setTo(e.target.value)}
              style={{
                width: '100%',
                background: 'var(--gf-surface)',
                border: '1px solid var(--gf-border)',
                color: 'var(--gf-text)',
                padding: '8px 12px',
                fontFamily: '"EB Garamond", Georgia, serif',
                fontSize: 15,
                borderRadius: 2,
              }}
            />
          </div>
          <Group justify="flex-end" mt="xs">
            <Button variant="subtle" onClick={() => setModalOpen(false)}>
              {t('actions.cancel')}
            </Button>
            <Button variant="filled" loading={loading} onClick={handleGenerate}>
              {t('reports.generate')}
            </Button>
          </Group>
        </Stack>
      </Modal>
    </AdminLayout>
  )
}
