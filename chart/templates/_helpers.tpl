{{- define "names.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "names.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "names.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{- define "names.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "names.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{- define "names.fullnameSuffix" -}}
{{- if and (hasKey . "suffix") (hasKey . "context") -}}
{{- $name := include "names.fullname" .context -}}
{{- printf "%s-%s" $name .suffix | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{- define "names.namespace" -}}
{{- default .Release.Namespace .Values.namespaceOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "labels.commonLabels" -}}
helm.sh/chart: {{ include "names.chart" . | quote }}
{{ include "labels.matchLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service | quote }}
{{- end }}

{{- define "labels.matchLabels" -}}
app.kubernetes.io/name: {{ include "names.name" . | quote }}
app.kubernetes.io/instance: {{ .Release.Name | quote }}
{{- end }}
