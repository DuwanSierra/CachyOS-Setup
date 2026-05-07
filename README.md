# CachyOS Setup

Automatizacion de la configuracion inicial de CachyOS usando Ansible. El objetivo es poder replicar el entorno completo en una instalacion nueva corriendo un solo comando.

## Que incluye

| Rol | Que instala |
|-----|-------------|
| `podman` | podman, podman-compose, buildah |
| `oh_my_zsh` | zsh + oh-my-zsh, lo setea como shell por defecto |
| `vscode` | Visual Studio Code (build oficial de Microsoft con marketplace completo, via AUR) |

---

## Estructura del proyecto

```
CachyOS-Setup/
├── ansible/
│   ├── ansible.cfg          # Configuracion base de Ansible
│   ├── requirements.yml     # Colecciones de Ansible necesarias
│   ├── inventory/
│   │   └── hosts.yml        # Inventario (localhost)
│   ├── playbooks/
│   │   └── setup.yml        # Playbook principal
│   └── roles/
│       ├── podman/          # Containers sin daemon (alternativa a Docker)
│       ├── oh_my_zsh/       # Shell + framework de configuracion zsh
│       └── vscode/          # Editor con marketplace de Microsoft
├── install.sh               # Script de bootstrap (instala dependencias y colecciones)
├── skills-lock.json         # Lock file de las skills de IA instaladas
└── .gitignore
```

---

## Como usarlo

### 1. Clonar el repositorio

```bash
git clone <url-del-repo> ~/CachyOS-Setup
cd ~/CachyOS-Setup
```

### 2. Correr el script

```bash
./install.sh
```

Eso es todo. El script se encarga de todo en orden:

1. Verifica que `yay` este disponible (viene por defecto en CachyOS)
2. Instala `ansible` y `curl` via pacman si no estan presentes
3. Instala la coleccion `community.general` de Ansible
4. Corre el playbook automaticamente

Pedira la contrasena de sudo una sola vez al inicio del playbook. No hace falta ningun `cd` ni correr comandos adicionales.

> No corras el script como root. Usa tu usuario normal; el script maneja sudo internamente donde lo necesita.

### 3. Verificar la instalacion

```bash
podman --version
zsh --version
code --version
```

---

## Como agregar un paquete nuevo

### Paquete de los repos oficiales (pacman)

1. Crear la carpeta del rol:

   ```bash
   mkdir -p ansible/roles/nombre_paquete/tasks
   ```

2. Crear `ansible/roles/nombre_paquete/tasks/main.yml`:

   ```yaml
   ---
   - name: Install nombre_paquete
     community.general.pacman:
       name: nombre_paquete
       state: present
     become: true
   ```

3. Agregar el rol al playbook `ansible/playbooks/setup.yml`:

   ```yaml
   roles:
     - podman
     - oh_my_zsh
     - vscode
     - nombre_paquete   # <-- agregar aqui
   ```

### Paquete del AUR (yay)

Mismo proceso pero en `tasks/main.yml` usar este patron idempotente:

```yaml
---
- name: Check if paquete_aur is already installed
  ansible.builtin.command:
    cmd: pacman -Q paquete_aur
  register: pkg_check
  changed_when: false
  failed_when: false

- name: Install paquete_aur via yay
  ansible.builtin.command:
    cmd: yay -S --noconfirm paquete_aur
  when: pkg_check.rc != 0
  changed_when: true
```

---

## Skills de IA instaladas

Este proyecto usa [skills.sh](https://skills.sh) para extender las capacidades del agente de IA con conocimiento especializado en Ansible y DevOps.

El archivo `skills-lock.json` registra las versiones instaladas (equivalente a `package-lock.json`). Las skills en si viven en `.agents/` que esta en el `.gitignore`.

Para reinstalar las skills en un entorno nuevo:

```bash
npx skills add aj-geddes/useful-ai-prompts@ansible-automation -y
npx skills add akin-ozer/cc-devops-skills@ansible-generator -y
npx skills add akin-ozer/cc-devops-skills@ansible-validator -y
npx skills add claude-office-skills/skills@devops-automation -y
```

| Skill | Para que sirve |
| ----- | -------------- |
| `ansible-automation` | Guias y buenas practicas generales de Ansible |
| `ansible-generator` | Generar playbooks y roles desde descripciones en lenguaje natural |
| `ansible-validator` | Validar y revisar playbooks por errores y malas practicas |
| `devops-automation` | Flujos de trabajo DevOps generales |

---

## Proximos pasos planeados

- [ ] Carpeta `dotfiles/` con configuraciones de zsh, git, y otras herramientas
- [ ] Mas roles: fuentes, temas, herramientas CLI
- [ ] Playbook separado para actualizaciones del sistema
