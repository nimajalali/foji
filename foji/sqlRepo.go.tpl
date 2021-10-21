// Code generated by foji {{ version }}, template: {{ templateFile }}; DO NOT EDIT.

package pg

import (
    "context"
    "fmt"

    "{{.Params.Package}}"
{{- range .Imports }}
    "{{ . }}"
{{- end }}
)

{{- range .Queries }}
{{- $resultType := $.GetType .Result.TypeParam $.PackageName }}

{{- if .Result.GenerateType }}
// {{.Result.Type}} represents a result from '{{.Name}}'.
type {{.Result.Type}} struct {
{{- range .Result.Params.ByOrdinal }}
    {{ pascal .Name }} {{ $.GetType . $.PackageName }}  `json:"{{ .Name }},omitempty"` // {{ .Type }}
{{- end }}
}
{{- end }}

// {{.Name}} returns {{ $resultType }}
// {{.Comment}}
func (r Repo) {{ .Name }}(ctx context.Context{{if gt (len .Params) 0}},{{end}} {{ $.Parameterize .Params.ByOrdinal "%s %s" $.PackageName }}) ({{ if .IsType "query" }}[]{{ end }}*{{$resultType}}, error) {
    query := `{{ backQuote .SQL }}`

    {{- if .IsType "query" }}
    q, err := r.db.Query(ctx, query{{if gt (len .Params) 0}},{{end}} {{ csv (.Params.ByQuery.Names.Camel)}})
    if err != nil {
        return nil, fmt.Errorf(("{{.Name}}.Query:%w", err)
    }
    var result []*{{ $resultType }}
    for q.Next() {
        row := {{ $resultType }}{}
        err := q.Scan({{ csv (.Result.Params.ByQuery.Names.Pascal.Sprintf "&row.%s")}})
        if err != nil {
            return nil, fmt.Errorf(("{{.Name}}.Scan:%w", err)
        }
        result = append(result, &row)
    }

    return result, nil
    {{- else }}
    q := r.db.QueryRow(ctx, query{{if gt (len .Params) 0}},{{end}} {{ csv (.Params.ByQuery.Names.Camel) }})
        {{/*        return scanOne{{$goName}}(q)*/}}
    {{- end }}
}
{{- end }}
