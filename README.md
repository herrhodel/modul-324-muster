# BBZBL Modul 324: Web-Applikation Musterlösung

Beispiel einer Applikation mit CI/CD Pipeline in die AWS Academy Umgebung.

- Es wird die AWS Umgebung mit Hilfe von [Terraform](https://developer.hashicorp.com/terraform/intro) aufgesetzt
- Es wird eine Web-Applikation in die AWS Umgebung mit Hilfe von [Kamal](https://kamal-deploy.org/) deployed
- Standardmässig wird die app im Ordner [`./app`](./app) deployed

> [!NOTE]
> Dieses Repository dient als **Muster** um die Projekte im Modul 324 umzusetzen.
> Ihr dürft alles von hier rauben.

> [!IMPORTANT]
> Zum Starten des Projekts, verwendet bitte das Repository [modul-324-starter](https://github.com/herrhodel/modul-324-starter)
> Es ist besser leer zu starten und Schritt für Schritt von hier zu kopieren.

## :file_folder: Ordnerstruktur

### [`/docs`](./docs/README.md)

Der Ordner `/docs` beinhaltet allgemeine Dokumentation. Hier könnt Ihr eure Gedanken
zum Projekt in `markdown`-Dateien niederschreiben.

> [!IMPORTANT]
> :file_folder: **`./docs/reflections`**
>
> - Jedes Projektmitglied sollte in diesem Ordner seine Sprint Reflexionen erfassen.
> - Am besten erstellt jeder einen Unterordner `/docs/reflections/ihr-nachname`.
> - Für jede Sprint-Reflexion sollte eine neue Datei erstellt werden.

### [`/app`](./app)

Der Ordner [`/app`](./app) beinhaltet alle Dateien die benötigt werden um eine Applikation als docker image zu erstellen.
Das darin liegende [`/app/Dockerfile`](./app/Dockerfile) beinhaltet die Beschreibung vom Image.

> [!NOTE]
> Dies ist die Standardapplikation, ein einfacher nginx Webserver, um das deployment nach AWS zu testen

Ihr solltet in eurem Projekt eine eigene Applikation erstellen.

### [`/terraform`](./terraform/README.md)

Der Ordner [`/terraform`](./terraform/) beinhaltet die Konfiguration der AWS Umgebung. Terraform ermöglicht es für alle
die AWS Umgebung einheitlich, automatisch aufzusetzen. Zusätzlich beinhaltet es utility Scripts um z.B.
die aktuelle IP vom Server herauszufinden.

### [`/kamal`](./kamal/README.md)

Der Ordner [`/kamal`](./kamal) beinhaltet die Konfiguration um ein Dockerfile Docker-image mit Hilfe des
Utility-Frameworks [Kamal](https://kamal-deploy.org/) zu deployen.

Es ist möglich eine Web-Applikation inclusive einer Datenbank auf eine beliebige VM zu deployen.

### [`/.github`](./.github)

Im Ordner [`.github`](./.github) befinden sich GitHub spezifische Dateien. Dies sind in unserem Fall vor allem
GitHub Action Workflows im Unterordner [.github/workflows](./.github/workflows).
Dieser beinhaltet folgende Dateien:

- **Setup Infrastructure on Amazon AWS** [`./.github/workflows/aws-infrastructure.yml`](./.github/workflows/aws-infrastructure.yml)

  Die Action "Setup Infrastructure on Amazon AWS" verbindet sich mit der AWS Umgebung und erstellt
  alle AWS Ressourcen wie z.B. Netzwerk, Routing, Docker Registry und Ubuntu Instanz.

- **Deploy to Amazon AWS** [`./.github/workflows/deploy.yml`](./.github/workflows/deploy.yml)

  Die Action "Deploy to Amazon AWS" baut das Docker-Image, ladet es in die Docker-Registry der AWS Umgebung
  und startet das Docker-Image als Container auf der Ubuntu VM.

- **Terraform via GHCR-backed state** [`./.github/workflows/terraform.yml`](./.github/workflows/terraform.yml)

  Die Action "Terraform via GHCR-backed state" verwaltet Terraform State verschlüsselt in GitHub Container Registry (GHCR).
  Siehe [Dokumentation](./docs/terraform-state-ghcr.md) für Details zur Konfiguration.

- **Terraform Destroy** [`./.github/workflows/terraform-destroy.yml`](./.github/workflows/terraform-destroy.yml)

  Manuelle Workflow zum sicheren Zerstören der Terraform-Infrastruktur mit Bestätigungsschritt.

- **Terraform State Pruning** [`./.github/workflows/terraform-prune-states.yml`](./.github/workflows/terraform-prune-states.yml)

  Automatische monatliche Bereinigung alter Terraform State-Versionen in GHCR.

### [`/.devcontainer`](./.devcontainer)

Im Ordner [`.devcontainer`](./.devcontainer) befindet sich das `Dockerfile` für den [DevContainer](https://containers.dev/) sowie auch die Spezifikation des devcontainers.
Das `./.devcontainer/Dockerfile` dient dazu eine einheitliche Entwicklungsumgebung für alle Projektmitglieder zur Verfügung zu stellen.

> [!IMPORTANT]
>
> - 🛝 **Optional: Ihr müsst keinen Devcontainer verwenden!** Verschwendet keine Zeit, wenn ihr es nicht bereits kennt, oder gewillt seit Freizeit darin zu investieren.
> - ✅ Zuerst sollte Docker-Desktop auf dem Computer installiert und gestartet sein!
> - ❗ Der Devcontainer brauch den Port 3000, wenn bereits ein Prozess auf dem Port gestartet ist kann der Container nicht gestartet werden.

#### Starten vom Devcontainer im Terminal

```bash
## Starten
docker compose up devcontainer -d
## Ein Terminal im Container starten
docker exec -it devcontainer /bin/bash
```

#### Starten vom DevContainer in VS-Code

- Link zur Doku auf der Modulwebseite
- Offizielle Doku: [Developing inside a Container](https://code.visualstudio.com/docs/devcontainers/containers)

### [`./local-template`](./local-template)

Der Ordner [`./local-template`](./local-template) beinhaltet Beispieldateien, wenn man im DevContainer mit Hilfe
der `aws-cli` und `kamal` direkt auf die AWS-Umgebung zugreifen möchte.

> [!IMPORTANT]
>
> **Optional**, das Modul kommt auch ohne den Ordner aus.

> [!CAUTION]
> In diesen Ordner müssen Credentials kopiert werden. Diese sollen **NIE** eingecheckt werden!
>
> - :exclamation: Der Ordner muss nach `local` umbenannt werden bevor die Credentials eingefügt werden
> - :bulb: Der Ordner `local` befindet sich im `.gitignore` und wird nicht eingecheckt
