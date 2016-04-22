import processing.core.PApplet;
import processing.serial.*;
import java.util.Arrays;


class LedCubeProtocol
{
  private Serial ledPort;
  private byte[] state = new byte[8];

  LedCubeProtocol(PApplet parent, int rate)
  {
    ledPort = new Serial(parent, Serial.list()[0], rate);;
  }
  
  private Boolean isBitSet(byte b, int bit)
  {
    return (b & (1 << bit)) != 0;
  }
  
  Boolean getLed(int x, int y, int z)
  {
    int byteN = 2 * y + z / 2;
    return isBitSet(state[byteN], x + 4 * (z % 2));
  }
  
  void drawLine(int x1, int y1, int z1, int x2, int y2, int z2)
  {
    // Bresenham's line algorithm
      int i, dx, dy, dz, l, m, n, x_inc, y_inc, z_inc, err_1, err_2, dx2, dy2, dz2;
      int[] point = new int[3];
      
      point[0] = x1;
      point[1] = y1;
      point[2] = z1;
      dx = x2 - x1;
      dy = y2 - y1;
      dz = z2 - z1;
      x_inc = (dx < 0) ? -1 : 1;
      l = abs(dx);
      y_inc = (dy < 0) ? -1 : 1;
      m = abs(dy);
      z_inc = (dz < 0) ? -1 : 1;
      n = abs(dz);
      dx2 = l << 1;
      dy2 = m << 1;
      dz2 = n << 1;
      
      if ((l >= m) && (l >= n)) {
          err_1 = dy2 - l;
          err_2 = dz2 - l;
          for (i = 0; i < l; i++) {
              setLed(point[0], point[1], point[2]);
              if (err_1 > 0) {
                  point[1] += y_inc;
                  err_1 -= dx2;
              }
              if (err_2 > 0) {
                  point[2] += z_inc;
                  err_2 -= dx2;
              }
              err_1 += dy2;
              err_2 += dz2;
              point[0] += x_inc;
          }
      } else if ((m >= l) && (m >= n)) {
          err_1 = dx2 - m;
          err_2 = dz2 - m;
          for (i = 0; i < m; i++) {
              setLed(point[0], point[1], point[2]);
              if (err_1 > 0) {
                  point[0] += x_inc;
                  err_1 -= dy2;
              }
              if (err_2 > 0) {
                  point[2] += z_inc;
                  err_2 -= dy2;
              }
              err_1 += dx2;
              err_2 += dz2;
              point[1] += y_inc;
          }
      } else {
          err_1 = dy2 - n;
          err_2 = dx2 - n;
          for (i = 0; i < n; i++) {
              setLed(point[0], point[1], point[2]);
              if (err_1 > 0) {
                  point[1] += y_inc;
                  err_1 -= dz2;
              }
              if (err_2 > 0) {
                  point[0] += x_inc;
                  err_2 -= dz2;
              }
              err_1 += dy2;
              err_2 += dx2;
              point[2] += z_inc;
          }
      }
      setLed(point[0], point[1], point[2]);
  }
  
  void drawPoint(int x, int y, int z)
  {
    setLed(x, y, z);
  }
  
  void reset()
  {
    Arrays.fill(state, (byte)0);
  }
  
  void setLed(int x, int y, int z)
  {
    int byteN = 2 * y + z / 2;
    state[byteN] |= 1 << (x + 4 * (z % 2));
  }
  
  void setRandomLed()
  {
    reset();
    setLed(int(random(4)), int(random(4)), int(random(4)));
  }
  
  void update()
  {
    byte[] newPackage = new byte[10];
    Arrays.fill(newPackage, byte(0));
    newPackage[0] |= 1 << 7;
    
    int index = 1;
    for (byte b : state)
    {
      for (int i = 0; i < 8; i++)
      {
        if (isBitSet(b, 7 - i))
          newPackage[index / 8] |= 1 << (7 - index % 8);
        index++;
        if (index % 8 == 0)
          index++;
      }
    }

    for(byte b : newPackage)
      ledPort.write(b);
  }
}
