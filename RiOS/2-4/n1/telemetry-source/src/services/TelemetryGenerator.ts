import { logger } from '../utils/logger';

export interface TelemetryPoint {
  id: string;
  timestamp: Date;
  measurement: string;
  value: number;
  unit: string;
  quality: 'excellent' | 'good' | 'fair' | 'poor';
}

export class TelemetryGenerator {
  private measurements = [
    { name: 'voltage', unit: 'V', min: 210, max: 240 },
    { name: 'current', unit: 'A', min: 0, max: 100 },
    { name: 'power', unit: 'kW', min: 0, max: 500 },
    { name: 'frequency', unit: 'Hz', min: 49.5, max: 50.5 },
    { name: 'temperature', unit: '°C', min: 20, max: 80 }
  ];

  constructor(private sourceName: string) {}

  public generateData(): TelemetryPoint[] {
    const data: TelemetryPoint[] = [];
    const baseTime = new Date();

    this.measurements.forEach((measurement, index) => {
      const value = this.generateValue(measurement.min, measurement.max);
      const quality = this.determineQuality(value, measurement);

      data.push({
        id: `${this.sourceName}-${measurement.name}-${Date.now()}-${index}`,
        timestamp: new Date(baseTime.getTime() + index * 100),
        measurement: measurement.name,
        value: Number(value.toFixed(3)),
        unit: measurement.unit,
        quality
      });
    });

    logger.debug(`Сгенерированы данные для ${this.sourceName}`, {
      points: data.length
    });

    return data;
  }

  private generateValue(min: number, max: number): number {
    // Добавляем немного случайного шума
    const baseValue = (min + max) / 2;
    const variation = (max - min) * 0.1;
    return baseValue + (Math.random() - 0.5) * variation;
  }

  private determineQuality(value: number, measurement: any): TelemetryPoint['quality'] {
    const range = measurement.max - measurement.min;
    const normalized = (value - measurement.min) / range;

    if (normalized >= 0.4 && normalized <= 0.6) return 'excellent';
    if (normalized >= 0.3 && normalized <= 0.7) return 'good';
    if (normalized >= 0.2 && normalized <= 0.8) return 'fair';
    return 'poor';
  }
}