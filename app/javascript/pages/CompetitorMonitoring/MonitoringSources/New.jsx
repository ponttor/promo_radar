import { useTranslation } from 'react-i18next'
import AdminLayout from '../../../components/AdminLayout'
import MonitoringSourceForm from './_MonitoringSourceForm'

export default function New({ competitor, monitoring_source, errors, enum_options }) {
  const { t } = useTranslation()
  return (
    <AdminLayout title={t('monitoringSources.new', { name: competitor.name })}>
      <MonitoringSourceForm
        competitor={competitor}
        monitoring_source={monitoring_source}
        errors={errors}
        enum_options={enum_options}
        submitUrl={`/admin/competitor_monitoring/competitors/${competitor.id}/monitoring_sources`}
        method="post"
      />
    </AdminLayout>
  )
}
