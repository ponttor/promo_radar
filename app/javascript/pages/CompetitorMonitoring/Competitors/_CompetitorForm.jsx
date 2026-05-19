import { useForm } from '@inertiajs/react'
import { TextInput, Textarea, Switch, Button, Stack, Group } from '@mantine/core'
import { useTranslation } from 'react-i18next'

export default function CompetitorForm({ competitor, errors, submitUrl, method = 'post' }) {
  const { t } = useTranslation()
  const { data, setData, submit, processing } = useForm({
    name: competitor?.name || '',
    industry: competitor?.industry || '',
    country: competitor?.country || '',
    notes: competitor?.notes || '',
    active: competitor?.active ?? true,
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
          label={t('common.industry')}
          value={data.industry}
          onChange={(e) => setData('industry', e.target.value)}
        />
        <TextInput
          label={t('common.country')}
          value={data.country}
          onChange={(e) => setData('country', e.target.value)}
        />
        <Textarea
          label={t('common.notes')}
          rows={3}
          value={data.notes}
          onChange={(e) => setData('notes', e.target.value)}
        />
        <Switch
          label={t('common.active')}
          checked={data.active}
          onChange={(e) => setData('active', e.currentTarget.checked)}
        />
        <Group>
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
