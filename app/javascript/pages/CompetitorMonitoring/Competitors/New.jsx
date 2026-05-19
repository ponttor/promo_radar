import { useTranslation } from 'react-i18next'
import AdminLayout from '../../../components/AdminLayout'
import CompetitorForm from './_CompetitorForm'

export default function New({ competitor, errors }) {
  const { t } = useTranslation()
  return (
    <AdminLayout title={t('competitors.new')}>
      <CompetitorForm
        competitor={competitor}
        errors={errors}
        submitUrl="/admin/competitor_monitoring/competitors"
        method="post"
      />
    </AdminLayout>
  )
}
