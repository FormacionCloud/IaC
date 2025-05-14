resource "azurerm_linux_virtual_machine" "vm" {
  name                = "MyLinuxVM"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = "Standard_B1s"
  admin_username      = "azureuser"
  admin_password      = var.admin_password
  network_interface_ids = [
    azurerm_network_interface.nic.id,
  ]
  disable_password_authentication = false

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    name                 = "osdisk"
  }

  custom_data = base64encode(<<-EOF
              #!/bin/bash
              sudo apt-get update -y
              sudo apt-get install -y apache2 wget php libapache2-mod-php php-mysql
              sudo apt-get install -y mariadb-server
              sudo systemctl start apache2
              sudo systemctl enable apache2
              sudo systemctl start mariadb
              sudo systemctl enable mariadb
              echo "<?php phpinfo(); ?>" | sudo tee /var/www/html/index.php
              EOF
  )

  tags = {
    environment = "TerraformDemo"
  }
}
