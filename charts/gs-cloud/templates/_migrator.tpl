{{/* -----------------------------------------------------------
     Helper: build the FQDN for the legacy GeoServer service
*/}}
{{- define "migrator.source.url" -}}
{{ printf "http://%s.%s.svc.cluster.local:%d" .Values.migrator.source.service .Values.migrator.source.namespace .Values.migrator.source.port }}
{{- end }}

{{/* -----------------------------------------------------------
     Helper: full shell script (unchanged logic)
*/}}
{{- define "migrator.init.command" }}
- sh
- -c
- |
  set -euo pipefail
  TAR_PATH=/source_data/datadir.tar.gz
  if [ ! -f "$TAR_PATH" ]; then
    echo "▶ Downloading data directory …"
    curl -sS -u "${GS_USER}:${GS_PASS}" \
      "{{ include "migrator.source.url" . }}/geoserver/rest/backup/directory?prepare=full&target=datadir.tar.gz" \
      -o "$TAR_PATH"
  else
    echo "▶ Archive already present – skipping download"
  fi
  echo "▶ Extracting …"
  mkdir -p /target_data
  tar --no-same-owner --no-same-permissions -xzf "$TAR_PATH" -C /target_data
  echo "✔️  Extraction complete"
{{- end }}


{{/* gateway extras template is always defined … */}}
{{- define "migrator.gateway.extras" }}
{{- if .Values.migrator.enabled }}
volumes:
  - name: olddatadir
    persistentVolumeClaim:
      claimName: {{ .Values.migrator.source.pvc.name }}
  - name: datadir
    persistentVolumeClaim:
      claimName: {{ .Values.migrator.conversor.pvc.name }}
initContainers:
  - name: datadir-migrator
    image: curlimages/curl:8.7
    env:
      - name: GS_USER
        valueFrom:
          secretKeyRef: { name: old-gs-credentials, key: username }
      - name: GS_PASS
        valueFrom:
          secretKeyRef: { name: old-gs-credentials, key: password }
    command: {{ include "migrator.init.command" . | nindent 6 }}
    volumeMounts:
      - name: olddatadir
        mountPath: /source_data
        readOnly: true
      - name: datadir
        mountPath: /target_data
{{- end }}            {{/* ← closes IF */}}
{{- end }}            {{/* ← closes DEFINE */}}