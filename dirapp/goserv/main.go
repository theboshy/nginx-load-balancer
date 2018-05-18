package main

import (
	"log"
	"os"

	"github.com/gin-gonic/gin"
)

func main() {

	r := gin.Default()
	r.GET("/go", func(c *gin.Context) {
		c.JSON(200, gin.H{
			"message": os.Getenv("MESSAGE"),
		})
	})

	if err := r.Run(":8080"); err != nil {
		log.Fatalf("Failed to run server: %v", err)
	}
}
