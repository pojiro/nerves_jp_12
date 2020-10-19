defmodule NervesJp12.PararellControll do
  def blink(pin) do
    NervesJp12.LedController.blink(pin, 10_000, 500)
    NervesJp12.LedController.blink(pin, 10_000, 400)
    NervesJp12.LedController.blink(pin, 10_000, 300)
    NervesJp12.LedController.blink(pin, 10_000, 200)
    NervesJp12.LedController.blink(pin, 10_000, 100)
  end
end
