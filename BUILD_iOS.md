# Сборка iOS через GitHub Actions + установка через Sideloadly

## 1. Залить проект на GitHub

В корне проекта (`c:\Users\Кирилл\OneDrive\Desktop\Ozon bank`):

```powershell
git init
git add .
git commit -m "Ozon Bank UI clone"
git branch -M main
git remote add origin https://github.com/<твой-логин>/<имя-репо>.git
git push -u origin main
```

После пуша вкладка **Actions** в репозитории автоматически запустит workflow `iOS Build (unsigned IPA)`.
Запустить вручную можно: **Actions → iOS Build (unsigned IPA) → Run workflow**.

## 2. Скачать IPA

Когда сборка зелёная:

1. Зайти в завершённый run.
2. Внизу страницы блок **Artifacts** → `ozon_bank-unsigned-ipa`.
3. Скачать zip, распаковать → получится `ozon_bank-unsigned.ipa`.

Это **неподписанный** IPA — именно такой и нужен Sideloadly.

## 3. Установка через Sideloadly

1. Установить Sideloadly: https://sideloadly.io/ (есть версия для Windows).
2. Подключить iPhone кабелем, разрешить «Доверять».
3. В Sideloadly:
   - **IPA**: перетащить `ozon_bank-unsigned.ipa`.
   - **Apple ID**: твой Apple ID (для бесплатного аккаунта подпись живёт 7 дней).
   - Нажать **Start**, ввести app-specific password если попросит.
4. На iPhone: **Настройки → Основные → VPN и управление устройством** → доверять профилю разработчика.
5. Запустить приложение «ozon_bank».

## Замечания

- Bundle ID по умолчанию: `com.ozonbank.ozonBank`. Sideloadly при установке сам подменит его на свой (`com.<applеid>.ozonBank`) — нормально.
- Бесплатный Apple ID: подпись на 7 дней, до 3 приложений, и нужно переподписывать.
- Если хочешь signed IPA сразу из CI — нужен платный Apple Developer аккаунт и certs/profiles в GitHub Secrets (это другой workflow).
- Workflow закреплён на `flutter 3.24.5` и `Xcode 15.4` (macos-14). Если GitHub снимет образ — поменяй версии в `.github/workflows/ios-build.yml`.
