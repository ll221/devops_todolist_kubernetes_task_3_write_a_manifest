# Інструкція з розгортання ToDo App у Kubernetes

## Передумови

Перед початком переконайтесь що у вас установлено та налаштовано:

- **kubectl** — інструмент для керування Kubernetes кластером
- **docker** — для збірки та публікації образів
- Доступ до працюючого **Kubernetes кластера** (локального або хмарного)
- Акаунт на **Docker Hub** для публікації образів

---

## Крок 1: Підготовка Docker образу

### 1.1 Збірка Docker образу

```bash
docker build -t igorrrrrrrr/todoapp:3.0.0 .
```

### 1.2 Публікація образу на Docker Hub

```bash
docker login
docker push igorrrrrrrr/todoapp:3.0.0
```

---

## Крок 2: Застосування маніфестів у Kubernetes

### 2.1 Застосувати всі маніфести

```bash
# Namespace
kubectl apply -f .infrastructure/namespace.yml

# Busybox
kubectl apply -f .infrastructure/busybox.yml

# ToDo App
kubectl apply -f .infrastructure/todoapp-pod.yml
```

### 2.2 Перевірити статус подів

```bash
kubectl get pods -n todoapp
```

Очікуємо:
---

## Крок 3: Тестування через port-forward

### 3.1 Прокинути порт

Відкрийте новий термінал:

```bash
kubectl port-forward pod/todoapp 8080:8080 -n todoapp
```

### 3.2 Тестування health checks

В іншому терміналі:

```bash
# Readiness probe
curl http://localhost:8080/api/health/ready

# Liveness probe
curl http://localhost:8080/api/health/live
```

Очікуємо:
```json
{"status": "ready"}
{"status": "alive"}
```

### 3.3 Тестування API

```bash
curl http://localhost:8080/api/todos/
curl http://localhost:8080/api/todolists/
```

---

## Крок 4: Тестування через busyboxplus:curl

### 4.1 Отримати IP todoapp

```bash
kubectl get pod todoapp -n todoapp -o wide
```

Запомніть IP (наприклад `10.244.0.10`).

### 4.2 Вхід в busybox контейнер

```bash
kubectl exec -it busybox -n todoapp -- sh
```

Всередині контейнера:

```sh
# Замінити 10.244.0.10 на реальний IP

# Readiness probe
curl http://10.244.0.10:8080/api/health/ready

# Liveness probe
curl http://10.244.0.10:8080/api/health/live

# API
curl http://10.244.0.10:8080/api/todos/

# Вихід
exit
```

### 4.3 Альтернатива - без входу в контейнер

```bash
# Замінити 10.244.0.10 на реальний IP

kubectl exec busybox -n todoapp -- curl http://10.244.0.10:8080/api/health/ready
kubectl exec busybox -n todoapp -- curl http://10.244.0.10:8080/api/health/live
kubectl exec busybox -n todoapp -- curl http://10.244.0.10:8080/api/todos/
```

---

## Крок 5: Перевірка Probes

```bash
# Readiness probe
kubectl describe pod todoapp -n todoapp | grep -A 5 "Readiness"

# Liveness probe
kubectl describe pod todoapp -n todoapp | grep -A 5 "Liveness"
```

---

## Крок 6: Видалення ресурсів

```bash
kubectl delete -f .infrastructure/
```

---

## Корисні команди

```bash
# Логи
kubectl logs todoapp -n todoapp
kubectl logs todoapp -n todoapp -f

# Описання поду
kubectl describe pod todoapp -n todoapp

# События
kubectl get events -n todoapp

# Вхід в контейнер
kubectl exec -it todoapp -n todoapp -- bash
```

---

## Можливі проблеми

### ImagePullBackOff
Образ не знайдений на Docker Hub.
```bash
docker push igorrrrrrrr/todoapp:3.0.0
kubectl delete pod todoapp -n todoapp
kubectl apply -f .infrastructure/todoapp-pod.yml
```

### CrashLoopBackOff
Застосунок краша. Перевірте логи:
```bash
kubectl logs todoapp -n todoapp
```

### Readiness probe не проходить
Перевірите через port-forward:
```bash
kubectl port-forward pod/todoapp 8080:8080 -n todoapp
curl http://localhost:8080/api/health/ready
```