import { useState } from 'react'
import { useForm } from '@inertiajs/react'
import { TextInput, Switch, Button, Stack, Group, Table, Badge, Text, Select } from '@mantine/core'
import { useTranslation } from 'react-i18next'

const SOURCE_TYPES = ['website', 'instagram']

let _sourceCounter = 0

export default function CompetitorForm({ competitor, errors, submitUrl, method = 'post' }) {
  const { t } = useTranslation()

  const { data, setData, submit, processing } = useForm({
    name: competitor?.name || '',
    active: competitor?.active ?? true,
    monitoring_sources_attributes: (competitor?.monitoring_sources || []).map((s) => ({
      id: s.id,
      url: s.url,
      source_type: s.source_type,
      active: s.active ?? true,
      _destroy: false,
    })),
  })

  const [newSource, setNewSource] = useState({ url: '', source_type: 'website' })
  const [showAddRow, setShowAddRow] = useState(false)

  const visibleSources = data.monitoring_sources_attributes.filter((s) => !s._destroy)

  const addSource = () => {
    if (!newSource.url) return
    setData('monitoring_sources_attributes', [
      ...data.monitoring_sources_attributes,
      { _cid: ++_sourceCounter, url: newSource.url, source_type: newSource.source_type, active: true, _destroy: false },
    ])
    setNewSource({ url: '', source_type: 'website' })
    setShowAddRow(false)
  }

  const removeSource = (source) => {
    if (source.id) {
      setData('monitoring_sources_attributes',
        data.monitoring_sources_attributes.map((s) =>
          s.id === source.id ? { ...s, _destroy: true } : s
        )
      )
    } else {
      setData('monitoring_sources_attributes',
        data.monitoring_sources_attributes.filter((s) => s._cid !== source._cid)
      )
    }
  }

  const handleSubmit = (e) => {
    e.preventDefault()
    submit(method, submitUrl)
  }

  return (
    <form onSubmit={handleSubmit}>
      <Stack maw={600}>
        <TextInput
          label={t('common.name')}
          required
          value={data.name}
          onChange={(e) => setData('name', e.target.value)}
          error={errors?.name?.[0]}
        />
        <Switch
          label={t('common.active')}
          checked={data.active}
          onChange={(e) => setData('active', e.currentTarget.checked)}
        />

        <Text fw={500} mt="sm">{t('monitoringSources.sectionTitle')}</Text>

        {visibleSources.length > 0 && (
          <Table withTableBorder>
            <Table.Thead>
              <Table.Tr>
                <Table.Th>{t('common.url')}</Table.Th>
                <Table.Th>{t('common.type')}</Table.Th>
                <Table.Th></Table.Th>
              </Table.Tr>
            </Table.Thead>
            <Table.Tbody>
              {visibleSources.map((source) => (
                <Table.Tr key={source.id ?? source._cid}>
                  <Table.Td><Text size="sm">{source.url}</Text></Table.Td>
                  <Table.Td>
                    <Badge variant="light" color={source.source_type === 'instagram' ? 'grape' : 'blue'}>
                      {source.source_type}
                    </Badge>
                  </Table.Td>
                  <Table.Td>
                    <Button size="xs" variant="light" color="red"
                      onClick={() => removeSource(source)}>
                      {t('actions.delete')}
                    </Button>
                  </Table.Td>
                </Table.Tr>
              ))}
            </Table.Tbody>
          </Table>
        )}

        {showAddRow ? (
          <Group align="flex-end">
            <TextInput
              placeholder="https://..."
              value={newSource.url}
              onChange={(e) => setNewSource({ ...newSource, url: e.target.value })}
              style={{ flex: 1 }}
            />
            <Select
              data={SOURCE_TYPES.map((v) => ({ value: v, label: v }))}
              value={newSource.source_type}
              onChange={(v) => setNewSource({ ...newSource, source_type: v })}
              w={140}
            />
            <Button size="sm" onClick={addSource}>{t('actions.add')}</Button>
            <Button size="sm" variant="subtle" onClick={() => setShowAddRow(false)}>
              {t('actions.cancel')}
            </Button>
          </Group>
        ) : (
          <Button variant="light" size="sm" w="fit-content" onClick={() => setShowAddRow(true)}>
            {t('monitoringSources.addSource')}
          </Button>
        )}

        <Group mt="sm">
          <Button type="submit" loading={processing}>{t('actions.save')}</Button>
          <Button variant="subtle" component="a"
            href="/admin/competitor_monitoring/competitors">
            {t('actions.cancel')}
          </Button>
        </Group>
      </Stack>
    </form>
  )
}
