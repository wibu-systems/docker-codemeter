{{/*
Expand the name of the chart.
*/}}
{{- define "codemeter.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "codemeter.fullname" -}}
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
{{- define "codemeter.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "codemeter.labels" -}}
helm.sh/chart: {{ include "codemeter.chart" . }}
{{ include "codemeter.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "codemeter.selectorLabels" -}}
app.kubernetes.io/name: {{ include "codemeter.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
License volumes
*/}}
{{- define "codemeter.licenseVolumes" -}}
{{- $found_license_secrets := list -}}
{{- range (concat .Values.config.licenseFile .Values.config.cmCloudCredentials) -}}
{{- if (not (has .secretName $found_license_secrets)) }}
- name: license-{{ .secretName }}
  secret:
    secretName: {{ .secretName }}
{{- $found_license_secrets = append $found_license_secrets .secretName -}}
{{- end }}
{{- end }}
{{- end }}

{{/*
License volume mounts
*/}}
{{- define "codemeter.licenseVolumeMounts" -}}
{{- range . }}
- name: license-{{ .secretName }}
  mountPath: /licenses/{{ .secretName }}/{{ .secretKey }}
  subPath: {{ .secretKey }}
{{- end }}
{{- end }}

{{/*
Licenses CM_LICENSE_FILE env
*/}}
{{- define "codemeter.cmLicenseFileEnv" -}}
{{- $license_paths := list -}}
{{- range .Values.config.licenseFile }}
{{- $license_paths = append $license_paths (printf "/licenses/%s/%s" .secretName .secretKey) }}
{{- end }}
- name: CM_LICENSE_FILE
  value: {{ quote (join "," $license_paths) }}
{{- end }}

{{/*
Cloud Licenses CM_CMCLOUD_CREDENTIALS env
*/}}
{{- define "codemeter.cmCloudLicenseFileEnv" -}}
{{- $license_paths := list -}}
{{- range .Values.config.cmCloudCredentials }}
{{- $license_paths = append $license_paths (printf "/licenses/%s/%s" .secretName .secretKey) }}
{{- end }}
- name: CM_CMCLOUD_CREDENTIALS
  value: {{ quote (join "," $license_paths) }}
{{- end }}
