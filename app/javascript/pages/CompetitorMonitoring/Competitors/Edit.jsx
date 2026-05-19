import { useTranslation } from 'react-i18next'
import AdminLayout from '../../../components/AdminLayout'
import CompetitorForm from './_CompetitorForm'

export default function Edit({ competitor, errors }) {
  const { t } = useTranslation()
  return (
    <AdminLayout title={t('competitors.edit', { name: competitor.name })}>
      <CompetitorForm
        competitor={competitor}
        errors={errors}
        submitUrl={`/admin/competitor_monitoring/competitors/${competitor.id}`}
        method="patch"
      />
    </AdminLayout>
  )
}
