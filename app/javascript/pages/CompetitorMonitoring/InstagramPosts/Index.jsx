import { Table, Badge, Button, Group, Text, Anchor, Alert, Notification } from '@mantine/core'
import { useTranslation } from 'react-i18next'
import { useForm, usePage } from '@inertiajs/react'
import AdminLayout from '../../../components/AdminLayout'

function formatDate(dateStr, lang) {
  if (!dateStr) return '—'
  return new Intl.DateTimeFormat(lang === 'sk' ? 'sk-SK' : 'en-GB', {
    day: '2-digit', month: '2-digit', year: 'numeric',
    hour: '2-digit', minute: '2-digit',
  }).format(new Date(dateStr))
}

function postTypeColor(type) {
  const colors = { reel: 'grape', video: 'blue', carousel: 'orange', photo: 'gray' }
  return colors[type] || 'gray'
}

export default function Index({ competitor, monitoring_source, posts, credential_active }) {
  const { t, i18n } = useTranslation()
  const { flash } = usePage().props
  const fetchForm = useForm({})
  const fetchUrl = `/admin/competitor_monitoring/competitors/${competitor.id}/monitoring_sources/${monitoring_source.id}/instagram_posts/fetch`

  const rows = posts.map((p) => (
    <Table.Tr key={p.id}>
      <Table.Td>
        <Text size="sm">{formatDate(p.posted_at, i18n.resolvedLanguage)}</Text>
      </Table.Td>
      <Table.Td>
        <Badge color={postTypeColor(p.post_type)} variant="light">{p.post_type || '—'}</Badge>
      </Table.Td>
      <Table.Td>
        <Text size="sm" style={{ maxWidth: 320 }} lineClamp={2}>{p.caption || '—'}</Text>
      </Table.Td>
      <Table.Td>{p.likes_count ?? '—'}</Table.Td>
      <Table.Td>{p.comments_count ?? '—'}</Table.Td>
      <Table.Td>
        <Anchor href={p.permalink} target="_blank" size="sm">↗</Anchor>
      </Table.Td>
    </Table.Tr>
  ))

  return (
    <AdminLayout title={t('instagramPosts.title', { name: monitoring_source.name })}>
      <Group mb="md" justify="space-between">
        <Anchor
          href={`/admin/competitor_monitoring/competitors/${competitor.id}/monitoring_sources`}
          size="sm">
          {t('instagramPosts.backToSources')}
        </Anchor>
        <Group gap="xs">
          <Badge color={credential_active ? 'green' : 'red'} variant="light" size="sm">
            {credential_active
              ? t('instagramPosts.sessionActive')
              : t('instagramPosts.sessionExpired')}
          </Badge>
          <Button
            size="xs"
            variant="light"
            loading={fetchForm.processing}
            onClick={() => fetchForm.post(fetchUrl)}
          >
            Fetch now
          </Button>
        </Group>
      </Group>

      {flash?.notice && (
        <Notification color="green" mb="md" withCloseButton={false}>{flash.notice}</Notification>
      )}
      {flash?.alert && (
        <Notification color="red" mb="md" withCloseButton={false}>{flash.alert}</Notification>
      )}

      {!credential_active && (
        <Alert color="red" mb="md">
          {t('instagramPosts.sessionExpired')}
        </Alert>
      )}

      {posts.length === 0 ? (
        <Text c="dimmed">{t('instagramPosts.empty')}</Text>
      ) : (
        <Table striped highlightOnHover>
          <Table.Thead>
            <Table.Tr>
              <Table.Th>{t('common.postedAt')}</Table.Th>
              <Table.Th>{t('common.postType')}</Table.Th>
              <Table.Th>{t('common.caption')}</Table.Th>
              <Table.Th>{t('common.likes')}</Table.Th>
              <Table.Th>{t('common.comments')}</Table.Th>
              <Table.Th>{t('common.link')}</Table.Th>
            </Table.Tr>
          </Table.Thead>
          <Table.Tbody>{rows}</Table.Tbody>
        </Table>
      )}
    </AdminLayout>
  )
}
