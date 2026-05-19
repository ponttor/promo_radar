import { useForm } from '@inertiajs/react'
import { TextInput, Select, Switch, Button, Stack, Group } from '@mantine/core'
import { useTranslation } from 'react-i18next'

function toSelectData(keys) {
  return (keys || []).map((k) => ({ value: k, label: k }))
}

export default function MonitoringSourceForm({
  competitor, monitoring_source, errors, enum_options, submitUrl, method = 'post'
}) {
  const { t } = useTranslation()
  const { data, setData, submit, processing } = useForm({
    name: monitoring_source?.name || '',
    url: monitoring_source?.url || '',
    source_type: monitoring_source?.source_type || 'website',
    fetch_strategy: monitoring_source?.fetch_strategy || 'http',
    extractor_type: monitoring_source?.extractor_type || 'hybrid',
    check_frequency: monitoring_source?.check_frequency || 'daily',
    active: monitoring_source?.active ?? true,
  })

  const handleSubmit = (e) => {
    e.preventDefault()
    submit(method, submitUrl)
  }

  return (
    <form onSubmit={handleSubmit}>
      <Stack maw={480}>
        <TextInput
          label={t('common.name')}
          required
          value={data.name}
          onChange={(e) => setData('name', e.target.value)}
          error={errors?.name?.[0]}
        />
        <TextInput
          label={t('common.url')}
          required
          placeholder="https://..."
          value={data.url}
          onChange={(e) => setData('url', e.target.value)}
          error={errors?.url?.[0]}
        />
        <Select
          label={t('monitoringSources.sourceType')}
          data={toSelectData(enum_options?.source_types)}
          value={data.source_type}
          onChange={(v) => setData('source_type', v)}
        />
        <Select
          label={t('monitoringSources.fetchStrategy')}
          data={toSelectData(enum_options?.fetch_strategies)}
          value={data.fetch_strategy}
          onChange={(v) => setData('fetch_strategy', v)}
        />
        <Select
          label={t('monitoringSources.extractorType')}
          data={toSelectData(enum_options?.extractor_types)}
          value={data.extractor_type}
          onChange={(v) => setData('extractor_type', v)}
        />
        <Select
          label={t('monitoringSources.checkFrequency')}
          data={toSelectData(enum_options?.check_frequencies)}
          value={data.check_frequency}
          onChange={(v) => setData('check_frequency', v)}
        />
        <Switch
          label={t('common.active')}
          checked={data.active}
          onChange={(e) => setData('active', e.currentTarget.checked)}
        />
        <Group>
          <Button type="submit" loading={processing}>{t('actions.save')}</Button>
          <Button variant="subtle" component="a"
            href={`/admin/competitor_monitoring/competitors/${competitor.id}/monitoring_sources`}>
            {t('actions.cancel')}
          </Button>
        </Group>
      </Stack>
    </form>
  )
}
