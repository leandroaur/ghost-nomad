import os
import json
import markdown
from datetime import datetime

def convert_md_to_json(md_file):
    # Ler o conteúdo do arquivo markdown
    with open(md_file, 'r', encoding='utf-8') as file:
        md_content = file.read()

    # Converter o conteúdo markdown para HTML
    html_content = markdown.markdown(md_content)

    # Obter o título do arquivo
    title = os.path.splitext(os.path.basename(md_file))[0]

    # Obter a data atual
    current_date = datetime.now()
    year = current_date.year
    month = current_date.month

    # Estrutura do post em formato JSON para o Ghost
    post = {
        "posts": [
            {
                "title": title,
                "status": "draft",  # Ou "published" se desejar publicar automaticamente
                "mobiledoc": json.dumps({
                    "version": "0.3.1",
                    "atoms": [],
                    "cards": [
                        ["markdown", {"markdown": md_content}]
                    ],
                    "markups": [],
                    "sections": [[10, 0]]
                }),
                "published_at": current_date.isoformat(),
                "created_at": current_date.isoformat(),
                "updated_at": current_date.isoformat(),
                "slug": title.lower().replace(" ", "-")
            }
        ]
    }

    # Salvar o JSON gerado em um arquivo
    json_filename = f"texts/{title}.json"
    with open(json_filename, 'w', encoding='utf-8') as json_file:
        json.dump(post, json_file, ensure_ascii=False, indent=4)

    print(f"Arquivo JSON gerado: {json_filename}")

# Caminho do arquivo Markdown
md_file = 'texts/nomad-setup.md'

# Converter o Markdown para JSON
convert_md_to_json(md_file)
