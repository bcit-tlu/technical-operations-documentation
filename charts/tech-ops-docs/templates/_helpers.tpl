{{/*
Expand the name of the chart.
*/}}
{{- define "tech-ops-docs.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "tech-ops-docs.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "tech-ops-docs.labels" -}}
helm.sh/chart: {{ include "tech-ops-docs.name" . }}-{{ .Chart.Version | replace "+" "_" }}
{{ include "tech-ops-docs.selectorLabels" . }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "tech-ops-docs.selectorLabels" -}}
app.kubernetes.io/name: {{ include "tech-ops-docs.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}
