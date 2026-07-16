#include <zephyr/kernel.h>
#include <zephyr/device.h>
#include <zephyr/drivers/adc.h>
#include <zephyr/drivers/sensor.h>
#include <zephyr/logging/log.h>

LOG_MODULE_REGISTER(adc_logger, CONFIG_LOG_DEFAULT_LEVEL);

static struct k_work_delayable adc_work;
const struct device *vbatt_dev = DEVICE_DT_GET(DT_PATH(vbatt));

static void adc_read_work_handler(struct k_work *work)
{
    //struct sensor_value value;
    sensor_sample_fetch(vbatt_dev);
    /* Перезапускаем таймер */
    k_work_reschedule(&adc_work, K_MSEC(1000));
}

/* Инициализация нашего модуля при старте системы */
static int adc_logger_init(void)
{
    LOG_INF("Init ADC logger...");

    /* Настраиваем задачу в очереди и запускаем первый проход */
    k_work_init_delayable(&adc_work, adc_read_work_handler);
    k_work_reschedule(&adc_work, K_MSEC(1000));

    LOG_INF("ADC logger started.");
    return 0;
}

/* Регистрируем инициализацию на этапе APPLICATION (после инициализации драйверов) */
SYS_INIT(adc_logger_init, APPLICATION, CONFIG_APPLICATION_INIT_PRIORITY);
