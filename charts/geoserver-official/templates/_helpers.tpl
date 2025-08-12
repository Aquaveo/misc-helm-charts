{{/*
Expand the name of the chart.
*/}}
{{- define "geoserver-official.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "geoserver-official.fullname" -}}
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
Create chart name and version as used by the chart label.
*/}}
{{- define "geoserver-official.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "geoserver-official.labels" -}}
helm.sh/chart: {{ include "geoserver-official.chart" . }}
{{ include "geoserver-official.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "geoserver-official.selectorLabels" -}}
app.kubernetes.io/name: {{ include "geoserver-official.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "geoserver-official.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "geoserver-official.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
GeoServer image tag
*/}}
{{- define "geoserver-official.imageTag" -}}
{{- default .Chart.AppVersion .Values.image.tag }}
{{- end }}

{{/*
GeoServer data directory path
*/}}
{{- define "geoserver-official.dataDir" -}}
/opt/geoserver_data
{{- end }}

{{/*
Additional libs directory path
*/}}
{{- define "geoserver-official.additionalLibsDir" -}}
/opt/additional_libs
{{- end }}

{{/*
Additional fonts directory path
*/}}
{{- define "geoserver-official.additionalFontsDir" -}}
/opt/additional_fonts
{{- end }}
