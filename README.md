# Monolith-Config

### "Modular, reproducible, general-purpose NixOS configuration ready to take on the desktop world."
### "Not yet stable, use as reference only until ready"

## Discription 

Monolith-Config embraces the "batteries-included" approach without sacrificing modularity. It’s opinionated where it helps newcomers, but fully editable for experts. Everything is commented, organized into clear sections, and follows current NixOS best practices. Monolith works as a great reference config for the next NixOS configs that change the world.

## Features

- **Atomic rollbacks**: No more broken systems after updates. 
- **Version-locked packages**: Fully reproducible environments down the git commit.
- **GPU support out of the box**: Nvidia and AMD drivers are fully setup and tuned, just uncomment!
- **Secure by default**: Basic firewall, Fail2Ban, and SSH hardening.
- **AI/ML-ready**: Setup ROCm workarounds (AMD), Cuda (Nivida), Ollama, and OpenWebUI. Just uncomment what you need!
- **Desktop-optimized**: KDE Plasma 6, Pipewire audio, SDDM, and all the GUI apps you need!
- **Productivity aliases**: Fish shell aliases for automated system maintenance and updates!
- **Automatic cleanup tool**: Custom script to retain only recent generations and garbage-collect safely.

### AI Disclosure
This project is mostly hand written, but AI had a part in the automatic cleanup script. All commits that use AI tools MUST say they used AI, and must be tested by humans. 
