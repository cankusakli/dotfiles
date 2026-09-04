# Yeni bir Mac'e kurulum

Bu repo GitHub'da (`bengisugultekin/dotfiles`) hazır durumda. Yeni bir Mac'e
aynı kurulumu yapmak, çoğunlukla repoyu klonlayıp `bootstrap.sh`'ı
çalıştırmaktan ibaret. Script'in kapsamadığı birkaç manuel adım var, aşağıda
sırayla listelendi.

## 0) Önkoşullar (script'ten önce, elle)

- **Xcode Command Line Tools**: `xcode-select --install` (git için gerekli).
- **Homebrew**: bu repo Homebrew'u yönetmiyor (bilinçli tercih — mevcut
  cask/formula'ları silmesini istemedik). Elle kur: https://brew.sh
- **SSH erişimi** (`git@github-personal:...` remote'u kullanmak için):
  - Yeni bir SSH key üret veya eskisini taşı, GitHub hesabına ekle.
  - `~/.ssh/config`'e `github-personal` host alias'ını tanımla, örn:
    ```
    Host github-personal
        HostName github.com
        User git
        IdentityFile ~/.ssh/id_ed25519_personal
    ```
  - Bu adım atlanırsa repoyu `https://github.com/bengisugultekin/dotfiles.git`
    ile de klonlayabilirsin, ama bu durumda push için ayrıca kimlik doğrulaman
    gerekir.

## 1) Repoyu klonla

```bash
mkdir -p ~/github/bengisugultekin
git clone git@github-personal:bengisugultekin/dotfiles.git ~/github/bengisugultekin/dotfiles
cd ~/github/bengisugultekin/dotfiles
```

## 2) bootstrap.sh'ı çalıştır

```bash
./bootstrap.sh
```

Bu script:
1. Nix kurulu değilse Determinate Nix'i kurar.
2. Repoyu `~/.dotfiles`'a symlink'ler (home.nix'in `mkOutOfStoreSymlink`
   çağırdığı yer burası).
3. `flake.nix`'teki `user = "..."` satırını mevcut kullanıcı adınla
   karşılaştırır, uyuşmazsa senden onay isteyip düzeltir.
4. İlk `darwin-rebuild switch`'i çalıştırır.

**Önemli:** `sudo` şifre istediği için bunu kendi interaktif terminalinde
(Terminal.app/iTerm) çalıştır — bir asistan/otomasyon oturumunda değil, sudo
TTY hatası verir.

Kurulum bittiğinde ileride değişiklik yapınca `./bootstrap.sh` yerine
`./rebuild.sh` kullan (aynı işi yapar, tekrar Nix kurulum kontrolü yapmaz).

## 3) Script'in yapmadığı manuel adımlar

Bunlar bilinçli olarak Nix/home-manager dışında bırakıldı, her yeni makinede
elle tekrarlanmalı:

**a) herdr'nin kendisini kur** (config'i home-manager symlink'liyor ama
programın kendisi Nix/Homebrew ile yönetilmiyor):
```bash
brew install herdr
```

**b) `~/.zshrc`'ye şu bloğu ekle** (zsh plugin'leri + alias'lar — home-manager
sadece paketleri ve `~/.config/zsh-plugins/*.zsh` symlink'lerini kurar, `.zshrc`
kasıtlı olarak yönetilmiyor çünkü mevcut kişisel zshrc'yi ezmesin):
```bash
[[ -f "$HOME/.config/zsh-plugins/zsh-autosuggestions.zsh" ]] && source "$HOME/.config/zsh-plugins/zsh-autosuggestions.zsh"
[[ -f "$HOME/.config/zsh-plugins/zsh-syntax-highlighting.zsh" ]] && source "$HOME/.config/zsh-plugins/zsh-syntax-highlighting.zsh"
bindkey '^f' autosuggest-accept

alias ..='cd ..'
alias add='git add .'
alias push='git push'
alias pull='git pull'
alias m='git switch main'
```

**c) `~/.claude/settings.json` bilinçli olarak dahil edilmedi** — orijinal
repodaki bu dosya iş ortamına özgü (Trustly gateway, Bedrock model override,
`bypassPermissions`) ayarları ezerdi. Yeni Mac'te Claude Code ayarlarını
gerekiyorsa elle/ayrı kur.

## 4) Bu kurulumda kasıtlı olarak OLMAYAN şeyler

- **neovim** — denendi, beğenilmedi, tamamen kaldırıldı.
- **Homebrew yönetimi / `nix-homebrew`** — mevcut brew paketlerinin
  `cleanup=zap` ile silinme riski nedeniyle dahil edilmedi.
- **`system.defaults` (macOS sistem ayarları)** — dark mode zorlama, Dock/Finder
  ayarları vb. hiçbiri istenmedi.
- **`.pi/agent` config'i** ("pi" aracı) — kullanılmıyor.
- **`cc`/`co` alias'ları** (`--dangerously-skip-permissions` / `--full-auto`
  ile Claude/Codex çalıştıran kısayollar) — bilinçli olarak alınmadı.

## 5) Daha önce karşılaşılan hatalar ve çözümleri

- `nix flake check` → *"is not tracked by Git"*: `git add -N .` ile dosyaları
  commit atmadan git'e görünür yap.
- `sudo: a terminal is required to read the password`: bootstrap/rebuild'i
  arka plan bir ajan/otomasyon oturumunda değil, kendi terminalinde çalıştır.
- home-manager `~/.zshrc`/`~/.zshenv`'i **clobber etmeyi reddedip durursa**:
  bu, zaten dolu bir zshrc'yi home-manager'ın yönetmeye çalışmasından olur.
  Bu repo `programs.zsh`'ı hiç kullanmıyor, tam bu yüzden — eğer yine de
  görürsen `home.nix`'e yeni bir `programs.*` bloğu eklenmiş mi kontrol et.
- Zsh plugin `source` path'i bulunamıyorsa: nix profil yollarını elle tahmin
  etmeye çalışma — `home.nix`'teki `home.file` sabit symlink'lerini kullan
  (`~/.config/zsh-plugins/...`), bunlar her `switch`'te otomatik güncellenir.

## 6) Kurulumu doğrula

```bash
readlink -f ~/.config/wezterm     # → .dotfiles/home/.config/wezterm çıkmalı
readlink -f ~/.config/herdr
readlink -f ~/.claude/CLAUDE.md   # → .dotfiles/home/CLAUDE.md çıkmalı (içeriği: @AGENTS.md)
command -v herdr
darwin-rebuild --version
```
