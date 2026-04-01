# Weather App (UIKit + Metal)

Минималистичное погодное приложение, демонстрирующее использование архитектурного паттерна MVP, верстку кодом и графические шейдеры.
Приложение отображает текущую погоду в локации пользователя, почасовой прогноз на ближайшие сутки и прогноз на ближайшие 3 дня.

## Стек:
- ✅ Архитектура: MVP (Model-View-Presenter)
- ✅ UI: UIKit + SnapKit + UICollectionView Compositional Layout
- ✅ Concurrency: Async/Await (для сетевых запросов и геолокации)
- ✅ Graphics: Metal Shader (динамический фон неба)

## PREVIEW
<p align="left">
  <img src="https://github.com/tanelxen/weather/blob/master/screenshots/screenshot1.png" width="25%" />
  <img src="https://github.com/tanelxen/weather/blob/master/screenshots/screenshot2.png" width="25%" />
</p>

### Примечания:
- Для запуска необходимо получить API-ключ к [Weather API](https://www.weatherapi.com/) и вставить его в *Info.plist* в поле **WEATHER_API_KEY**.
- Зажмите область над названием города в течение секунды, чтобы открыть секретное меню редактирования отображения погоды.

## TODO
- [ ] доработать отрисовку облаков
- [ ] добавить поддержку дождя
- [ ] добавить поддержку снега
- [ ] добавить отображение солнца
- [ ] добавить отображение луны
- [ ] использовать conditions:code для более точной настройки шейдера
