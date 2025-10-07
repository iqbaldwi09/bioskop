package main

import (
	"log"
	"os"

	"github.com/iqbaldwi09/bioskop/internal/config"
	"github.com/iqbaldwi09/bioskop/internal/delivery"

	"github.com/gin-gonic/gin"
	"github.com/joho/godotenv"
)

func main() {
	err := godotenv.Load()
	if err != nil {
		log.Fatal("Error loading .env file")
	}

	db := config.InitDB()
	defer db.Close()

	r := gin.Default()

	delivery.InitRoutes(r, db)

	port := os.Getenv("APP_PORT")
	r.Run(":" + port)
}
