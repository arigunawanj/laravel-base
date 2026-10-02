# laravel-base

Image dasar untuk project Laravel: `php:8.4-fpm-alpine` + nginx + supervisor +
ekstensi `pdo_mysql pdo_pgsql gd zip intl bcmath pcntl opcache redis`.

Pakai di Dockerfile project:

```dockerfile
FROM ghcr.io/arigunawanj/laravel-base:8.4 AS runtime
```

Tag `8.4` bergerak (dibangun ulang tiap tanggal 1); `8.4-YYYYMMDD` tetap.
Butuh ekstensi tambahan? Tambahkan di Dockerfile repo ini, bukan di project.
